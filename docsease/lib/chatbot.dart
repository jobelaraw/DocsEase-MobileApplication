import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'tts_service.dart';
import 'chat_ai_service.dart';
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
import 'package:docsease/app_modals.dart';

// ─── ChatBot Screen Widget ───
class ChatBotScreen extends StatefulWidget {
  final String? conversationId;
  const ChatBotScreen({super.key, this.conversationId});

  // Allows Services screen to share preloaded offices data with chatbot
  static void setCachedOffices(List<Office> offices) {
    _ChatBotScreenState._cachedOffices = offices;
  }

  // Lets the header's new chat icon open the chat history drawer
  static void openHistory() {
    _ChatBotScreenState._activeState?._scaffoldKey.currentState?.openEndDrawer();
  }

  // Lets the header's search icon open the search bar
  static void openSearch() {
    _ChatBotScreenState._activeState?._openSearch();
  }

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

// ─── New Chat Icon: Square with a pencil, used in the header and history drawer ───
class NewChatIcon extends StatelessWidget {
  final Color color;
  final double size;
  const NewChatIcon({super.key, required this.color, this.size = 22});

  static const _svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>'
      '<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

// ─── Chat Message Model ───
class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final DateTime datetime;
  final List<ServiceDetail> relatedServices; // Related service cards shown below bot reply
  final bool isWelcome; // Greeting + random service cards at the start of a new chat
  final String? category; // Bot reply type from ChatAiService, e.g. specific_service or general
  final String? answeredTopic; // For specific_service: which part was answered (requirements, fees, ...)
  _ChatMessage({required this.text, required this.isUser, required this.time, required this.datetime, this.relatedServices = const [], this.isWelcome = false, this.category, this.answeredTopic});
}

// ─── ChatBot Screen State ───
class _ChatBotScreenState extends State<ChatBotScreen> {
  // Controllers
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TtsService _tts = TtsService();
  final ChatService _chatService = ChatService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final Stream<QuerySnapshot> _conversationsStream = _chatService.getConversations();
  static _ChatBotScreenState? _activeState; // Currently open chatbot, used by openHistory()
  static const _welcomeTitle = "Hey Citizen! I'm your DocsEase Bot, your assistant here in DocuGuide!";
  static const _welcomeSubtitle =
      'Nandito ako para tulungan ka sa mga dokumento, permit, at anumang prosesong kailangan mo. Ano ang gusto mong gawin ngayon?';

  // State variables
  int? _speakingIndex; // Index of currently speaking message (for TTS)
  String? _conversationId; // Current Firestore conversation ID
  final List<_ChatMessage> _messages = []; // All chat messages
  bool _isLoading = false; // Shows typing indicator when waiting for AI
  bool _isLoadingHistory = true; // Shows spinner while loading chat history
  late List<Map<String, dynamic>> _suggestions; // Floating suggestion chips data
  bool _showSuggestions = true; // Controls visibility of floating chips
  bool _isSelecting = false; // History drawer is in "delete multiple" mode
  final Set<String> _selectedIds = {}; // Conversations checked for deletion
  bool _isSearching = false; // Shows the search bar above the messages
  final TextEditingController _searchController = TextEditingController();
  List<int> _searchMatches = []; // Indexes of messages containing the query, oldest first
  int _currentMatch = 0; // Position in _searchMatches that is focused
  Map<int, GlobalKey> _matchKeys = {}; // Message index -> key, used to scroll to a match
  static List<Office> _cachedOffices = []; // Cached offices data from Firestore (shared across instances)

  // Connectivity
  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // ─── Initialization ───
  @override
  void initState() {
    super.initState();
    _activeState = this;
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

    if (_messages.isEmpty) _addWelcomeMessage();

    if (mounted) {
      setState(() => _isLoadingHistory = false);
    }
  }

  // ─── Welcome Message: Greeting + 3 random service cards at the start of every new chat ───
  void _addWelcomeMessage() {
    final now = DateTime.now();
    final services = _cachedOffices.expand((o) => o.services).where((s) => s.title.isNotEmpty).toList()
      ..shuffle();
    _messages.add(_ChatMessage(
      text: '$_welcomeTitle\n\n$_welcomeSubtitle',
      isUser: false,
      time: _formatTime(now),
      datetime: now,
      relatedServices: services.take(3).toList(),
      isWelcome: true,
    ));
  }

  // ─── Reset Chat: Stops TTS and clears the screen before switching conversations ───
  void _resetChat() {
    _tts.stop();
    _speakingIndex = null;
    _messages.clear();
    _suggestions = _generateRandomSuggestions();
    _showSuggestions = true;
    _clearSearch();
  }

  // ─── New Chat: Clears the screen, the conversation is created on the first message ───
  void _startNewChat() {
    _scaffoldKey.currentState?.closeEndDrawer();
    if (_isLoading) return;
    _resetToNewChat();
  }

  void _resetToNewChat() {
    setState(() {
      _resetChat();
      _conversationId = null;
      _addWelcomeMessage();
    });
  }

  // ─── Open Conversation: Loads a past conversation from the history drawer ───
  Future<void> _openConversation(String convoId) async {
    _scaffoldKey.currentState?.closeEndDrawer();
    if (_isLoading || convoId == _conversationId) return;
    setState(() {
      _resetChat();
      _conversationId = convoId;
      _isLoadingHistory = true;
    });

    await _loadConversation(convoId);
    if (!mounted || _conversationId != convoId) return; // User switched again while loading
    if (_messages.isEmpty) _addWelcomeMessage();
    setState(() => _isLoadingHistory = false);
  }

  // ─── Delete Options: Delete the current conversation or pick several to delete ───
  void _showDeleteOptions() {
    final currentId = _conversationId; // Null for a new chat that hasn't been saved yet
    DeleteChatOptionsModal.show(
      context,
      onDeleteCurrent: currentId == null ? null : () => _confirmDelete([currentId], closeDrawer: true),
      onDeleteMultiple: () => setState(() => _isSelecting = true),
    );
  }

  // ─── Confirm Delete: Deletes conversations, starts a new chat if the open one was deleted ───
  void _confirmDelete(List<String> ids, {bool closeDrawer = false}) {
    if (ids.isEmpty || _isLoading) return;
    DeleteConversationsModal.show(
      context,
      count: ids.length,
      onPrimary: () async {
        var failed = false;
        try {
          await _chatService.deleteConversations(ids);
        } catch (e) {
          debugPrint('Delete conversations error: $e');
          failed = true;
        }
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        if (failed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.translate(
              'Failed to delete conversation.',
              Provider.of<SettingsProvider>(context, listen: false).language,
            )),
          ));
          return;
        }

        _exitSelection();
        if (closeDrawer) _scaffoldKey.currentState?.closeEndDrawer();
        if (ids.contains(_conversationId)) _resetToNewChat();
      },
    );
  }

  void _toggleSelected(String convoId) {
    setState(() {
      if (!_selectedIds.remove(convoId)) _selectedIds.add(convoId);
    });
  }

  void _exitSelection() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  // ─── Search: Finds messages in the open conversation that contain the query ───
  void _openSearch() {
    _scaffoldKey.currentState?.closeEndDrawer();
    if (_isLoadingHistory) return;
    setState(() => _isSearching = true);
  }

  void _closeSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(_clearSearch);
  }

  void _clearSearch() {
    _isSearching = false;
    _searchController.clear();
    _searchMatches = [];
    _matchKeys = {};
  }

  void _runSearch(String query) {
    final q = query.trim().toLowerCase();
    final matches = [
      if (q.isNotEmpty)
        for (var i = 0; i < _messages.length; i++)
          if (!_messages[i].isWelcome && _messages[i].text.toLowerCase().contains(q)) i,
    ];
    setState(() {
      _searchMatches = matches;
      _matchKeys = {for (final i in matches) i: _matchKeys[i] ?? GlobalKey()};
      _currentMatch = matches.length - 1; // Start from the newest match
    });
    _scrollToMatch();
  }

  // Moves between matches: -1 = older, +1 = newer
  void _stepMatch(int step) {
    final next = _currentMatch + step;
    if (next < 0 || next >= _searchMatches.length) return;
    setState(() => _currentMatch = next);
    _scrollToMatch();
  }

  void _scrollToMatch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentMatch < 0 || _currentMatch >= _searchMatches.length) return;
      final matchContext = _matchKeys[_searchMatches[_currentMatch]]?.currentContext;
      if (matchContext == null) return;
      Scrollable.ensureVisible(
        matchContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ─── Search Highlight: Outlines matching messages, thicker for the current match ───
  BoxDecoration? _searchHighlight(int index, BorderRadius radius) {
    if (!_matchKeys.containsKey(index)) return null;
    final isCurrent = _searchMatches[_currentMatch] == index;
    return BoxDecoration(
      borderRadius: radius,
      border: Border.all(color: const Color(0xFFF59E0B), width: isCurrent ? 2.5 : 1),
    );
  }

  // ─── Load Conversation from Firestore + restore the cards saved with each bot reply ───
  Future<void> _loadConversation(String convoId) async {
    final messages = await _chatService.getMessages(convoId);
    if (_conversationId != convoId) return; // A different conversation was opened meanwhile
    if (mounted && messages.isNotEmpty) {
      _messages.clear();
      for (var msg in messages) {
        final dt = (msg['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        _messages.add(_ChatMessage(
          text: msg['text'] ?? '',
          isUser: msg['isUser'] ?? false,
          time: _formatTime(dt),
          datetime: dt,
          relatedServices: _servicesByIds(List<String>.from(msg['serviceIds'] ?? [])),
          isWelcome: msg['type'] == 'welcome',
          category: msg['category'],
          answeredTopic: msg['answeredTopic'],
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
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m[1]!)
        .replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => m[1]!)
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

  // ─── Send Message: Handles user input, calls OpenAI, shows related services ───
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
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _addError('API key not loaded.');
        setState(() => _isLoading = false);
        return;
      }

      // Offices may have failed to load when the screen opened (e.g., offline)
      if (_cachedOffices.isEmpty) _cachedOffices = await FirebaseServices().getOffices();

      // Recent turns so follow-ups like "magkano?" know which service is being discussed
      final history = _messages
          .where((m) => !m.isWelcome)
          .toList()
          .reversed
          .take(6)
          .toList()
          .reversed
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();

      final reply = await ChatAiService(apiKey: apiKey, offices: _cachedOffices).ask(history);
      final services = _servicesByIds(reply.serviceIds).take(3).toList();

      if (mounted) {
        final replyTime = DateTime.now();
        setState(() {
          _messages.add(_ChatMessage(
            text: reply.answer,
            isUser: false,
            time: _formatTime(replyTime),
            datetime: replyTime,
            relatedServices: services,
            category: reply.category,
            answeredTopic: reply.answeredTopic,
          ));
        });
        if (_chatService.isLoggedIn && _conversationId != null) {
          _chatService.saveMessage(_conversationId!, reply.answer, false, extra: {
            'category': reply.category,
            'answeredTopic': reply.answeredTopic,
            'serviceIds': services.map((s) => s.serviceId).toList(),
          });
        }
      }
    } on ChatAiException catch (e) {
      debugPrint('OpenAI error: $e');
      if (mounted) _addError('Error ${e.statusCode}: ${e.reasonPhrase}');
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
        final welcome = _messages[0];
        await _chatService.saveMessage(
          _conversationId!,
          welcome.text,
          false,
          extra: welcome.isWelcome
              ? {'type': 'welcome', 'serviceIds': welcome.relatedServices.map((s) => s.serviceId).toList()}
              : null,
        );
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
    if (_activeState == this) _activeState = null;
    _connectivitySubscription.cancel();
    _tts.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildHistoryDrawer(),
      onEndDrawerChanged: (isOpen) {
        if (!isOpen && _isSelecting) _exitSelection();
      },
      backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.tertiary,
      body: _isLoadingHistory
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          if (_isSearching) _buildSearchBar(),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  // While searching, build every message so any match can be scrolled to
                  scrollCacheExtent: _isSearching ? const ScrollCacheExtent.pixels(100000) : null,
                  reverse: true,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: _showSuggestions ? 60 : 20),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Reverse the index since list is reversed
                    final reversedIndex = _messages.length + (_isLoading ? 1 : 0) - 1 - index;
                    if (reversedIndex == _messages.length) return _buildTypingIndicator();
                    final msg = _messages[reversedIndex];
                    final showDate = _shouldShowDateSeparator(reversedIndex);
                    final messageWidget = msg.isWelcome
                        ? _buildWelcomeMessage(msg.relatedServices)
                        : msg.isUser
                        ? _buildUserMessage(msg.text, msg.time, reversedIndex)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBotMessage(msg.text, msg.time, reversedIndex),
                              if (msg.category == 'specific_service' && msg.relatedServices.isNotEmpty)
                                _buildFollowUpCards(msg.relatedServices.first, msg.answeredTopic)
                              else if (msg.relatedServices.isNotEmpty)
                                _buildRelatedServices(msg.relatedServices),
                            ],
                          );
                    
                    final matchKey = _matchKeys[reversedIndex];
                    final keyedMessage = matchKey != null
                        ? KeyedSubtree(key: matchKey, child: messageWidget)
                        : messageWidget;

                    if (showDate) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDateSeparator(msg.datetime),
                          keyedMessage,
                        ],
                      );
                    }
                    return keyedMessage;
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

  // ─── Search Bar: Query field, match counter, older/newer arrows, and close ───
  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final lang = Provider.of<SettingsProvider>(context).language;
    final total = _searchMatches.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: onSurface.withValues(alpha: 0.1), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.primary : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: onSurface.withValues(alpha: 0.5), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: _runSearch,
                      onSubmitted: (_) => _stepMatch(-1),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: AppLocalizations.translate('Search in conversation', lang),
                        hintStyle: GoogleFonts.inter(color: onSurface.withValues(alpha: 0.5), fontSize: 14),
                      ),
                    ),
                  ),
                  if (_searchController.text.trim().isNotEmpty)
                    Text(
                      total == 0 ? '0/0' : '${total - _currentMatch}/$total',
                      style: GoogleFonts.inter(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            color: onSurface,
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: _currentMatch > 0 ? () => _stepMatch(-1) : null,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            color: onSurface,
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: _currentMatch < total - 1 ? () => _stepMatch(1) : null,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            color: onSurface,
            icon: const Icon(Icons.close),
            onPressed: _closeSearch,
          ),
        ],
      ),
    );
  }

  // ─── Chat History Drawer: New chat, delete options, and past conversations ───
  Widget _buildHistoryDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final lang = Provider.of<SettingsProvider>(context).language;
    final screenWidth = MediaQuery.of(context).size.width;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Drawer(
      width: screenWidth > 400 ? 300 : screenWidth * 0.75,
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFE5F6FF),
      shape: const RoundedRectangleBorder(),
      // Disabled while the bot is replying so the reply lands in the right conversation
      child: AbsorbPointer(
        absorbing: _isLoading,
        child: Opacity(
          opacity: _isLoading ? 0.5 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NEW CHAT + DELETE BUTTONS (or selection bar when deleting multiple) ---
              Container(
                color: colorScheme.primary,
                padding: const EdgeInsets.all(12),
                child: _isSelecting ? _buildSelectionBar(lang, textColor) : Row(
                  children: [
                    Expanded(
                      child: _buildDrawerButton(
                        onTap: _startNewChat,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NewChatIcon(color: textColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.translate('New Chat', lang),
                              style: GoogleFonts.inter(
                                color: isDark ? Colors.white : colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildDrawerButton(
                      onTap: _showDeleteOptions,
                      child: Icon(Icons.delete_outline, color: textColor, size: 24),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  AppLocalizations.translate('Chat History', lang),
                  style: GoogleFonts.inter(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),

              // --- CONVERSATION LIST ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _conversationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final conversations = snapshot.data?.docs ?? [];
                    if (conversations.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          AppLocalizations.translate('No conversations yet.', lang),
                          style: GoogleFonts.inter(color: textColor.withValues(alpha: 0.5), fontSize: 13),
                        ),
                      );
                    }

                    // Newest first, grouped under Today / Yesterday / Previous 7 Days / ...
                    final items = <Widget>[];
                    String? currentGroup;
                    for (final convo in conversations) {
                      final data = convo.data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'Untitled';
                      // Null for a moment while a new chat's server timestamp is pending
                      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                      final group = _historyGroup(updatedAt);
                      final isSelected = _selectedIds.contains(convo.id);
                      final isHighlighted = _isSelecting ? isSelected : convo.id == _conversationId;

                      if (group != currentGroup) {
                        items.add(Padding(
                          padding: EdgeInsets.fromLTRB(16, currentGroup == null ? 4 : 16, 16, 4),
                          child: Text(
                            AppLocalizations.translate(group, lang).toUpperCase(),
                            style: GoogleFonts.inter(
                              color: textColor.withValues(alpha: 0.55),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ));
                        currentGroup = group;
                      }

                      items.add(InkWell(
                        onTap: _isSelecting ? () => _toggleSelected(convo.id) : () => _openConversation(convo.id),
                        child: Container(
                          color: isHighlighted ? colorScheme.primary.withValues(alpha: isDark ? 0.6 : 0.1) : null,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              if (_isSelecting)
                                Icon(
                                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: isSelected && !isDark ? colorScheme.primary : textColor,
                                  size: 18,
                                )
                              else
                                Icon(Icons.chat_bubble_outline, color: textColor, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(color: textColor, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _historyTimeLabel(updatedAt, group),
                                style: GoogleFonts.inter(color: textColor.withValues(alpha: 0.55), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ));
                    }

                    return ListView(padding: EdgeInsets.zero, children: items);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── History Group: Date section a conversation falls under, by its last activity ───
  String _historyGroup(DateTime date) {
    final now = DateTime.now();
    final days = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(date.year, date.month, date.day))
        .inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days <= 7) return 'Previous 7 Days';
    if (days <= 30) return 'Previous 30 Days';
    return 'Older';
  }

  // ─── History Time Label: "10:42 AM" for today, "May 18" for older, with year if not this year ───
  String _historyTimeLabel(DateTime date, String group) {
    if (group == 'Today') return _formatTime(date);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final label = '${months[date.month - 1]} ${date.day}';
    return date.year == DateTime.now().year ? label : '$label, ${date.year}';
  }

  // ─── Selection Bar: Cancel, selected count, and delete for "delete multiple" mode ───
  Widget _buildSelectionBar(String lang, Color textColor) {
    const red = Color(0xFFEF4444);
    final hasSelection = _selectedIds.isNotEmpty;

    return Row(
      children: [
        _buildDrawerButton(
          onTap: _exitSelection,
          child: Icon(Icons.close, color: textColor, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            AppLocalizations.translate('{n} selected', lang).replaceAll('{n}', '${_selectedIds.length}'),
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Opacity(
          opacity: hasSelection ? 1 : 0.5,
          child: _buildDrawerButton(
            onTap: hasSelection ? () => _confirmDelete(_selectedIds.toList()) : null,
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: red, size: 22),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.translate('Delete', lang),
                  style: GoogleFonts.inter(color: red, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Drawer Button: White rounded button on the drawer's blue header ───
  Widget _buildDrawerButton({required VoidCallback? onTap, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 42,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Center(child: child),
          ),
        ),
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

  // ─── Services By IDs: Looks up cached services, skipping any that no longer exist ───
  List<ServiceDetail> _servicesByIds(List<String> ids) {
    final allServices = _cachedOffices.expand((o) => o.services).toList();
    return [
      for (final id in ids) ...allServices.where((s) => s.serviceId == id).take(1),
    ];
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

  // ─── Build Date Separator: Small pill with "TODAY", "YESTERDAY", or the date ───
  Widget _buildDateSeparator(DateTime date) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFC4E1F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppLocalizations.translate(_formatDateLabel(date), lang).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? Colors.white60 : const Color(0xFF7A8C95),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Welcome Message: Greeting headline and random service cards for a new chat ───
  Widget _buildWelcomeMessage(List<ServiceDetail> services) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.translate(_welcomeTitle, lang),
            style: GoogleFonts.inter(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: isDark ? Colors.white : const Color(0xFF222425),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _welcomeSubtitle,
            style: GoogleFonts.inter(fontSize: 14, height: 1.4, color: onSurface.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 18),
          ...services.map(_buildWelcomeServiceCard),
        ],
      ),
    );
  }

  // ─── Welcome Service Card: Icon tile, name, description, and arrow; opens the service ───
  Widget _buildWelcomeServiceCard(ServiceDetail service) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final description = service.getDescription(lang);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? Theme.of(context).colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            SlideRoute(page: InformationScreen(detail: service)),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: onSurface.withValues(alpha: 0.08), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: UIHelper.getBgColorForService(service.title),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(UIHelper.getIconForService(service.title), size: 30, color: Colors.black87),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.getTitle(lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 12, height: 1.3, color: onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFEEF2F7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward, size: 18, color: isDark ? Colors.white : const Color(0xFF3D72DF)),
                ),
              ],
            ),
          ),
        ),
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
    return _buildSuggestionCard(
      icon: UIHelper.getIconForService(service.title),
      iconBackground: UIHelper.getBgColorForService(service.title),
      title: service.getTitle(lang),
      subtitle: service.getDescription(lang),
      onTap: () => Navigator.push(
        context,
        SlideRoute(page: InformationScreen(detail: service)),
      ),
    );
  }

  // Follow-up topics offered under a specific-service answer: key, label, icon, question (English, Filipino)
  static const _followUpTopics = [
    ('requirements', 'Requirements', Icons.checklist_rounded,
        'What are the requirements for {s}?', 'Ano ang mga requirements para sa {s}?'),
    ('steps', 'Step-by-step process', Icons.format_list_numbered_rounded,
        'What are the steps for {s}?', 'Ano ang mga hakbang para sa {s}?'),
    ('fees', 'Fees', Icons.payments_outlined,
        'How much are the fees for {s}?', 'Magkano ang bayad para sa {s}?'),
    ('persons_in_charge', 'Persons in charge', Icons.badge_outlined,
        'Who is in charge of {s}?', 'Sino ang namamahala sa {s}?'),
    ('processing_time', 'Processing time', Icons.schedule_rounded,
        'How long does {s} take?', 'Gaano katagal ang {s}?'),
  ];

  // ─── Follow-Up Cards: Other topics about the service just answered (fees, steps, ...) ───
  Widget _buildFollowUpCards(ServiceDetail service, String? answeredTopic) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    final serviceTitle = service.getTitle(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = _followUpTopics.where((t) => t.$1 != answeredTopic).take(3);

    return Padding(
      padding: const EdgeInsets.only(left: 46, right: 46, top: 9, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppLocalizations.translate('More about', lang)} $serviceTitle',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 3),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              SlideRoute(page: InformationScreen(detail: service)),
            ),
            child: Text(
              '${AppLocalizations.translate('View full details', lang)} →',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...topics.map((topic) {
            final question = (lang == 'Filipino' ? topic.$5 : topic.$4).replaceAll('{s}', serviceTitle);
            return _buildSuggestionCard(
              icon: topic.$3,
              iconBackground: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
              title: AppLocalizations.translate(topic.$2, lang),
              subtitle: serviceTitle,
              onTap: () => _askFollowUp(question),
            );
          }),
        ],
      ),
    );
  }

  // ─── Ask Follow-Up: Sends a follow-up card's question as if the user typed it ───
  void _askFollowUp(String question) {
    if (_isLoading) return;
    _controller.text = question;
    _sendMessage();
  }

  // ─── Suggestion Card: Icon tile, title, one-line subtitle, chevron ───
  Widget _buildSuggestionCard({
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                color: iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
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
    const botBubbleRadius = BorderRadius.only(
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    );
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
                          borderRadius: botBubbleRadius,
                        ),
                        foregroundDecoration: _searchHighlight(index, botBubbleRadius),
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
  Widget _buildUserMessage(String text, String time, int index) {
    const userBubbleRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: 18, left: MediaQuery.of(context).size.width * 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: userBubbleRadius,
            ),
            foregroundDecoration: _searchHighlight(index, userBubbleRadius),
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
