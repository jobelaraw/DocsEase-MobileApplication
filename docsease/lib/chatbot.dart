import 'dart:async';
import 'dart:convert';
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

class ChatBotScreen extends StatefulWidget {
  final String? conversationId;
  const ChatBotScreen({super.key, this.conversationId});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  _ChatMessage({required this.text, required this.isUser, required this.time});
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TtsService _tts = TtsService();
  final ChatService _chatService = ChatService();
  int? _speakingIndex;
  String? _conversationId;
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isLoadingHistory = true;

  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _initMessages();
    _checkInitialConnection();

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

    // If no history was loaded, show default welcome message
    if (_messages.isEmpty) {
      _messages.add(_ChatMessage(
        text: "Hi! Ako si DocsEase Bot at Nandito ako para tulungan ka sa mga dokumento, permit, at anumang prosesong kailangan mo. Ano ang gusto mong gawin ngayon?",
        isUser: false,
        time: _formatTime(DateTime.now()),
      ));
    }

    if (mounted) {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _loadConversation(String convoId) async {
    final messages = await _chatService.getMessages(convoId);
    if (mounted && messages.isNotEmpty) {
      _messages.clear();
      for (var msg in messages) {
        _messages.add(_ChatMessage(
          text: msg['text'] ?? '',
          isUser: msg['isUser'] ?? false,
          time: _formatTime(
            (msg['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ),
        ));
      }
    }
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        isOnline = !results.contains(ConnectivityResult.none);
      });
    }
  }

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
        .replaceAll(RegExp(r'#+\s'), '')
        .replaceAll(RegExp(r'- '), '')
        .trim();
  }

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

  static String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _sendMessage() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMsg = _ChatMessage(text: text, isUser: true, time: _formatTime(DateTime.now()));
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Save to Firestore in background (don't block the AI call)
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

      final messages = [
        {
          'role': 'system',
          'content':
              'Ikaw si DocsEase Bot. Tagapayo sa government documents sa Pilipinas.'
              'GATEKEEPER RULE: Suriin ang buong mensahe ng user. Kung ang mensahe ay may kasamang request tungkol sa coding, math, programming, o kahit anong hindi kaugnay sa permits (kahit pa nabanggit ang salitang "permit"), REJECT the entire request.'
              'STRICT RESPONSE: Kung mayroong off-topic na bahagi, sumagot LAMANG ng: "Paumanhin, hindi ko kayang sagutin ang mga tanong na walang kinalaman sa mga proseso ng dokumento."'
              'BAWAL magbigay ng code, tutorials, o explanations sa labas ng government documents.'
              'FORMAT: Bullet points, bold **mahahalagang salita**, maikling talata.'
              'WIKA: Match user language (Tagalog/English).'
              'ORAS: Ang araw at oras ngayon ay ${DateTime.now()}.',
        },
        ..._messages
            .skip(1)
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
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        if (mounted) {
          setState(() {
            _messages.add(
              _ChatMessage(text: reply.trim(), isUser: false, time: _formatTime(DateTime.now())),
            );
          });
          // Save bot reply to Firestore in background
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

  void _saveUserMessage(String text) async {
    if (_conversationId == null) {
      _conversationId = await _chatService.createConversation(text);
    }
    if (_conversationId != null) {
      _chatService.saveMessage(_conversationId!, text, true);
    }
  }

  void _addError(String msg) {
    setState(() {
      _messages.add(_ChatMessage(text: msg, isUser: false, time: _formatTime(DateTime.now())));
    });
  }

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
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Reverse the index since list is reversed
                final reversedIndex = _messages.length + (_isLoading ? 1 : 0) - 1 - index;
                if (reversedIndex == _messages.length) return _buildTypingIndicator();
                final msg = _messages[reversedIndex];
                return msg.isUser
                    ? _buildUserMessage(msg.text, msg.time)
                    : _buildBotMessage(msg.text, msg.time, reversedIndex);
              },
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
