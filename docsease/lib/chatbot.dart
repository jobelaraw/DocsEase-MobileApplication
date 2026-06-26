import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'tts_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:docsease/app_localizations.dart';
import 'package:docsease/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_service.dart';
import 'package:docsease/firebase_services.dart';
import 'package:docsease/info_model.dart';
import 'package:docsease/information.dart';
import 'package:docsease/services.dart';
import 'package:docsease/navigator_transition.dart';

// ─── ChatBot Screen Widget ───
class ChatBotScreen extends StatefulWidget {
  final String? conversationId;
  const ChatBotScreen({super.key, this.conversationId});

  // Allows Services screen to share preloaded offices data with chatbot
  static void setCachedOffices(List<Office> offices) {
    _ChatBotScreenState._cachedOffices = offices;
  }

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

// ─── Chat Message Model ───
class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final DateTime datetime;
  final List<ServiceDetail> relatedServices; // Related service cards shown below bot reply
  _ChatMessage({required this.text, required this.isUser, required this.time, required this.datetime, this.relatedServices = const []});
}

// ─── ChatBot Screen State ───
class _ChatBotScreenState extends State<ChatBotScreen> {
  // Controllers
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TtsService _tts = TtsService();
  final ChatService _chatService = ChatService();

  // State variables
  int? _speakingIndex; // Index of currently speaking message (for TTS)
  String? _conversationId; // Current Firestore conversation ID
  final List<_ChatMessage> _messages = []; // All chat messages
  bool _isLoading = false; // Shows typing indicator when waiting for AI
  bool _isLoadingHistory = true; // Shows spinner while loading chat history
  late List<Map<String, dynamic>> _suggestions; // Floating suggestion chips data
  bool _showSuggestions = true; // Controls visibility of floating chips
  static List<Office> _cachedOffices = []; // Cached offices data from Firestore (shared across instances)

  // Connectivity
  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // ─── Initialization ───
  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _suggestions = _generateRandomSuggestions(); // Generate random suggestion chips
    _initData(); // Load offices + messages
    _checkInitialConnection(); // Check internet status

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (mounted) {
        setState(() {
          isOnline = !results.contains(ConnectivityResult.none);
        });
      }
    });
  }

  // ─── Load Messages: Fetches conversation history or shows welcome message ───
  Future<void> _initMessages() async {
    if (_conversationId != null) {
      await _loadConversation(_conversationId!);
    } else if (_chatService.isLoggedIn) {
      final convoId = await _chatService.getMostRecentConversationId();
      if (convoId != null && mounted) {
        _conversationId = convoId;
        await _loadConversation(convoId);
      }
    }

    if (_messages.isEmpty) {
      final now = DateTime.now();
      _messages.add(_ChatMessage(
        text: "Hi! Ako si DocsEase Bot at Nandito ako para tulungan ka sa mga dokumento, permit, at anumang prosesong kailangan mo. Ano ang gusto mong gawin ngayon?",
        isUser: false,
        time: _formatTime(now),
        datetime: now,
      ));
    }

    if (mounted) {
      setState(() => _isLoadingHistory = false);
    }
  }

  // ─── Load Conversation from Firestore + regenerate related services ───
  Future<void> _loadConversation(String convoId) async {
    final messages = await _chatService.getMessages(convoId);
    if (mounted && messages.isNotEmpty) {
      _messages.clear();
      String? lastUserText;
      for (var msg in messages) {
        final dt = (msg['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        final isUser = msg['isUser'] ?? false;
        List<ServiceDetail> related = [];
        if (!isUser && lastUserText != null) {
          related = _findRelatedServices(lastUserText);
          lastUserText = null;
        }
        if (isUser) lastUserText = msg['text'] ?? '';
        _messages.add(_ChatMessage(
          text: msg['text'] ?? '',
          isUser: isUser,
          time: _formatTime(dt),
          datetime: dt,
          relatedServices: related,
        ));
      }
    }
  }

  // ─── Check Initial Internet Connection ───
  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        isOnline = !results.contains(ConnectivityResult.none);
      });
    }
  }

  // ─── Strip Markdown: Removes formatting for TTS ───
  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
        .replaceAll(RegExp(r'#+\s'), '')
        .replaceAll(RegExp(r'- '), '')
        .trim();
  }

  // ─── Text-to-Speech: Toggle speaking for a message ───
  Future<void> _speak(String text, int index) async {
    if (_speakingIndex == index) {
      await _tts.stop();
      setState(() => _speakingIndex = null);
    } else {
      await _tts.stop();
      setState(() => _speakingIndex = index);
      await _tts.speak(
        _stripMarkdown(text),
        onDone: () {
          if (mounted) setState(() => _speakingIndex = null);
        },
      );
    }
  }

  // ─── Format Time: Converts DateTime to "12:00 PM" format ───
  static String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // ─── Send Message: Handles user input, calls Groq AI, shows related services ───
  Future<void> _sendMessage() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    final now = DateTime.now();
    final userMsg = _ChatMessage(text: text, isUser: true, time: _formatTime(now), datetime: now);
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _showSuggestions = false;
    });
    _controller.clear();
    _scrollToBottom();

    if (_chatService.isLoggedIn) {
      _saveUserMessage(text);
    }

    try {
      final apiKey = dotenv.env['GROQ_API'];
      if (apiKey == null || apiKey.isEmpty) {
        _addError('API key not loaded.');
        setState(() => _isLoading = false);
        return;
      }

      final relatedForCards = _findRelatedServices(text);

      final messages = [
        {
          'role': 'system',
          'content':
              'Ikaw si DocsEase Bot. Tagapayo sa government documents sa Pilipinas.'
              'RULES:'
              '1. If user greets (hi, hello, kamusta, etc): respond with a SHORT friendly greeting and ask how you can help with their document needs.'
              '2. If user asks GENERALLY about a service (how to get, pano kumuha, etc): respond with ONLY 1 SHORT sentence description. Do NOT mention any button or shortcut.'
              '3. If user asks SPECIFICALLY about requirements: list ONLY requirements.'
              '4. If user asks SPECIFICALLY about procedure/steps: list ONLY the steps.'
              '5. If user asks SPECIFICALLY about cost/fee/bayad: answer ONLY the cost.'
              '6. If user asks SPECIFICALLY about office/location/saan: answer ONLY the location.'
              '7. If user asks SPECIFICALLY about duration/time: answer ONLY the processing time.'
              '8. NEVER add extra info the user did not ask for.'
              '9. ONLY reject questions about coding, math, programming, personal advice, or topics completely unrelated to government services. Questions about permits, documents, certificates, offices ARE related - answer them.'
              'WIKA: Match user language (Tagalog/English).'
              'FORMAT: Keep answers short and direct. Use bullet points only when listing multiple items.',
        },
        ..._messages
            .skip(1)
            .toList()
            .reversed
            .take(4)
            .toList()
            .reversed
            .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text}),
      ];

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
            body: jsonEncode({
              'model': 'llama-3.1-8b-instant',
              'messages': messages,
              'temperature': 0.0,
              'max_tokens': 150,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        if (mounted) {
          final replyTime = DateTime.now();
          setState(() {
            _messages.add(
              _ChatMessage(text: reply.trim(), isUser: false, time: _formatTime(replyTime), datetime: replyTime, relatedServices: relatedForCards),
            );
          });
          if (_chatService.isLoggedIn && _conversationId != null) {
            _chatService.saveMessage(_conversationId!, reply.trim(), false);
          }
        }
      } else {
        debugPrint('Groq error: ${response.statusCode} ${response.body}');
        if (mounted) _addError('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Chatbot error: $e');
      if (mounted) _addError('Failed to connect. Please check your internet connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  // ─── Save User Message to Firestore ───
  void _saveUserMessage(String text) async {
    if (_conversationId == null) {
      _conversationId = await _chatService.createConversation(text);
      // Save the welcome message that was shown before user's first message
      if (_conversationId != null && _messages.isNotEmpty && !_messages[0].isUser) {
        await _chatService.saveMessage(_conversationId!, _messages[0].text, false);
      }
    }
    if (_conversationId != null) {
      _chatService.saveMessage(_conversationId!, text, true);
    }
  }

  // ─── Add Error Message to Chat ───
  void _addError(String msg) {
    final now = DateTime.now();
    setState(() {
      _messages.add(_ChatMessage(text: msg, isUser: false, time: _formatTime(now), datetime: now));
    });
  }

  // ─── Format Date Label: "Today", "Yesterday", or "Monday, Jan 1, 2025" ───
  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(msgDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ─── Check if Date Separator Should Show Between Messages ───
  bool _shouldShowDateSeparator(int index) {
    if (index == 0) return true;
    final curr = _messages[index].datetime;
    final prev = _messages[index - 1].datetime;
    return curr.year != prev.year || curr.month != prev.month || curr.day != prev.day;
  }

  // ─── Scroll Chat to Bottom ───
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _tts.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.tertiary,
      body: _isLoadingHistory
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  reverse: true,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: _showSuggestions ? 60 : 20),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Reverse the index since list is reversed
                    final reversedIndex = _messages.length + (_isLoading ? 1 : 0) - 1 - index;
                    if (reversedIndex == _messages.length) return _buildTypingIndicator();
                    final msg = _messages[reversedIndex];
                    final showDate = _shouldShowDateSeparator(reversedIndex);
                    final messageWidget = msg.isUser
                        ? _buildUserMessage(msg.text, msg.time)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBotMessage(msg.text, msg.time, reversedIndex),
                              if (msg.relatedServices.isNotEmpty)
                                _buildRelatedServices(msg.relatedServices),
                            ],
                          );
                    
                    if (showDate) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDateSeparator(msg.datetime),
                          messageWidget,
                        ],
                      );
                    }
                    return messageWidget;
                  },
                ),
                // Floating suggestion chips
                if (_showSuggestions)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: _buildSuggestionCards(),
                  ),
              ],
            ),
          ),

          // --- FIXED BOTTOM INPUT BAR ---
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFFF2F2F2),                      
                        borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.translate('Ask about your transaction...', Provider.of<SettingsProvider>(context).language),
                        hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Generate Random Suggestion Chips (Navigation, Office, Service) ───
  List<Map<String, dynamic>> _generateRandomSuggestions() {
    final random = Random();

    final navigations = [
      {'label': 'Go to Home', 'action': 'nav_0'},
      {'label': 'Go to Profile', 'action': 'nav_1'},
      {'label': 'Go to About', 'action': 'nav_2'},
      {'label': 'Go to Settings', 'action': 'nav_3'},
    ];

    final offices = [
      {'label': 'Business Permit & Licensing', 'action': 'office_BPLO'},
      {'label': 'City Civil Registry', 'action': 'office_OCCR'},
      {'label': "City Engineer's Office", 'action': 'office_OCE'},
    ];

    final services = [
      {'label': 'Business Permit', 'action': 'service_BPLO-NEW-BP'},
      {'label': 'Marriage Certificate', 'action': 'service_OCCR-MARRIAGE-LIC'},
      {'label': 'Building Permit', 'action': 'service_OCPDC-CLEARANCE-BUILDING'},
    ];

    return [
      navigations[random.nextInt(navigations.length)],
      offices[random.nextInt(offices.length)],
      services[random.nextInt(services.length)],
    ];
  }

  // ─── Handle Suggestion Chip Tap ───
  void _handleSuggestionTap(String action) {
    if (action.startsWith('nav_')) {
      final tabIndex = int.tryParse(action.replaceFirst('nav_', '')) ?? 0;
      Navigator.of(context).pop(tabIndex);
    } else if (action.startsWith('office_')) {
      final officeId = action.replaceFirst('office_', '');
      _navigateToOffice(officeId);
    } else if (action.startsWith('service_')) {
      _navigateToService(action.replaceFirst('service_', ''));
    }
  }

  // ─── Build Floating Suggestion Chips Widget ───
  Widget _buildSuggestionCards() {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _suggestions.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final label = AppLocalizations.translate(s['label'], lang);
            return Padding(
              padding: EdgeInsets.only(right: i < _suggestions.length - 1 ? 8 : 0),
              child: _buildSuggestionChip(
                label: label,
                onTap: () => _handleSuggestionTap(s['action']),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Build Individual Suggestion Chip ───
  Widget _buildSuggestionChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  // ─── Load Offices Data (fetches from Firestore if not cached) ───
  Future<void> _initData() async {
    // Use cached offices if available, otherwise fetch
    if (_cachedOffices.isEmpty) {
      _cachedOffices = await FirebaseServices().getOffices();
    }
    await _initMessages();
  }


  // ─── Find Related Services: Keyword matching against cached offices ───
  // Matches user's message keywords against service names (English + Filipino)
  // Returns 1 result for specific queries (2+ keyword matches)
  // Returns up to 3 results for broad queries (1 keyword match)
  List<ServiceDetail> _findRelatedServices(String userMessage) {
    if (_cachedOffices.isEmpty) return [];
    final msg = userMessage.toLowerCase();
    final allServices = _cachedOffices.expand((o) => o.services).toList();

    // Tagalog topic mappings
    const tagalogMap = {
      'negosyo': 'business',
      'permiso': 'permit',
      'kasal': 'marriage',
      'ikasal': 'marriage',
      'kapanganakan': 'birth',
      'pagtatayo': 'building',
      'konstruksyon': 'construction',
      'lisensya': 'license',
      'sertipiko': 'certificate',
      'clearance': 'clearance',
      'buwis': 'tax',
      'kamatayan': 'death',
      'patay': 'death',
      'namatay': 'death',
      'rehistro': 'registration',
      'pagreretiro': 'retirement',
      'reklamo': 'complaint',
      'espesyal': 'special',
      'okupasyon': 'occupancy',
      'elektrikal': 'electrical',
      'inspeksyon': 'inspection',
      'kalusugan': 'health',
      'bata': 'child',
      'renewal': 'renewal',
      'mag-renew': 'renewal',
    };

    // Words to ignore
    const skipWords = {'pano', 'paano', 'mag', 'ang', 'nga', 'nang', 'para', 'saan', 'ano', 'anong', 'gusto', 'kailangan', 'asikaso', 'papel', 'dokumento', 'proseso', 'kumuha', 'pagkuha'};

    // Extract meaningful topic keywords
    final words = msg.split(RegExp(r'[\s,?.!]+'));
    final topicKeywords = <String>[];
    for (var w in words) {
      if (w.length < 3 || skipWords.contains(w)) continue;
      if (tagalogMap.containsKey(w)) {
        topicKeywords.add(tagalogMap[w]!);
      } else {
        topicKeywords.add(w);
      }
    }

    if (topicKeywords.isEmpty) return [];

    // Score services by how many topic keywords match their name
    final scored = <ServiceDetail, int>{};
    for (var service in allServices) {
      final nameEn = service.title.toLowerCase();
      final nameFil = service.titleFil.toLowerCase();
      int score = 0;
      for (var kw in topicKeywords) {
        if (nameEn.contains(kw) || nameFil.contains(kw)) score++;
      }
      if (score > 0) scored[service] = score;
    }

    if (scored.isEmpty) return [];

    final sorted = scored.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topScore = sorted.first.value;

    // If top score is high (2+ keywords matched), it's a specific service - show only 1
    if (topScore >= 2) {
      return [sorted.first.key];
    }

    // For single keyword matches, only return services that share the SAME matched keyword
    // This prevents "certificate" matching unrelated certificate services
    final topService = sorted.first.key;
    final topNameEn = topService.title.toLowerCase();
    // Find which keyword matched the top result
    String? matchedKeyword;
    for (var kw in topicKeywords) {
      if (topNameEn.contains(kw)) {
        matchedKeyword = kw;
        break;
      }
    }
    if (matchedKeyword == null) return [topService];

    // Only return services that also match this specific keyword
    final filtered = sorted.where((e) {
      final name = e.key.title.toLowerCase();
      return name.contains(matchedKeyword!);
    }).take(3).map((e) => e.key).toList();
    return filtered;
  }

  // ─── Navigate to Office: Shows all services under an office ───
  void _navigateToOffice(String officeId) {
    final office = _cachedOffices.where((o) => o.officeId == officeId).firstOrNull;
    if (office != null && mounted) {
      final lang = Provider.of<SettingsProvider>(context, listen: false).language;
      Navigator.push(
        context,
        SlideRoute(
          page: SeeAllScreen(
            title: office.getOfficeName(lang),
            services: office.services,
            onTitleChange: (_) {},
          ),
        ),
      );
    }
  }

  // ─── Navigate to Service: Opens InformationScreen for a specific service ───
  void _navigateToService(String serviceId) {
    final allServices = _cachedOffices.expand((o) => o.services).toList();
    final service = allServices.where((s) => s.serviceId == serviceId).firstOrNull;
    if (service != null && mounted) {
      Navigator.push(
        context,
        SlideRoute(page: InformationScreen(detail: service)),
      );
    }
  }

  // ─── Build Date Separator ("Today", "Yesterday", etc.) ───
  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDateLabel(date),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15))),
        ],
      ),
    );
  }

  // ─── Build Related Services Section (shown below bot reply) ───
  Widget _buildRelatedServices(List<ServiceDetail> services) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    final isSpecific = services.length == 1;
    return Padding(
      padding: const EdgeInsets.only(left: 46, right: 46, top: 9, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSpecific
                ? '${AppLocalizations.translate('Quick Access for', lang)} ${services.first.getTitle(lang)}'
                : AppLocalizations.translate('Related Services', lang),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            isSpecific
                ? AppLocalizations.translate('Tap to view full details:', lang)
                : AppLocalizations.translate('Commonly requested document procedures:', lang),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          ...services.map((service) => _buildRelatedServiceCard(service)),
        ],
      ),
    );
  }

  // ─── Build Individual Related Service Card ───
  Widget _buildRelatedServiceCard(ServiceDetail service) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlideRoute(page: InformationScreen(detail: service)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: UIHelper.getBgColorForService(service.title),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                UIHelper.getIconForService(service.title),
                size: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.getTitle(lang),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (service.getDescription(lang).isNotEmpty)
                    Text(
                      service.getDescription(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build Typing Indicator (3 animated dots) ───
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: ClipOval(
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/chatbot_darkmode.png'
                    : 'assets/chatbot_icon.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,              
                borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  // ─── Build Bot Message Bubble ───
  Widget _buildBotMessage(String text, String time, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                child: ClipOval(
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/chatbot_darkmode.png'
                        : 'assets/chatbot_icon.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: isOnline
                    ? Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF39D236),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 1.5,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DocsEase Bot",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarkdownBody(
                              data: text,
                              styleSheet: MarkdownStyleSheet(
                                p: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                                strong: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                                listBullet: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withValues(alpha: 0.25),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _speak(text, index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _speakingIndex == index
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                              : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _speakingIndex == index ? Icons.stop : Icons.volume_up_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build User Message Bubble ───
  Widget _buildUserMessage(String text, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18, left: MediaQuery.of(context).size.width * 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Typing Dots Animation Widget ───
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
    );
    _animations = _controllers
        .map(
          (c) => Tween(
            begin: 0.0,
            end: -6.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
