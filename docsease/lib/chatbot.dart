import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'tts_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

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
  int? _speakingIndex;
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          "Hi! Ako si DocsEase Bot at Nandito ako para tulungan ka sa mga dokumento, permit, at anumang prosesong kailangan mo. Ano ang gusto mong gawin ngayon?",
      isUser: false,
      time: _formatTime(DateTime.now()),
    ),
  ];
  bool _isLoading = false;

  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    _checkInitialConnection();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (mounted) {
        setState(() {
          // If the result contains 'none', the user has no internet!
          isOnline = !results.contains(ConnectivityResult.none);
        });
      }
    });
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

    final userMsg = _ChatMessage(
      text: text,
      isUser: true,
      time: _formatTime(DateTime.now()),
    );
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

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
              'Ikaw si DocsEase Bot. Sumagot nang malinaw at maayos tungkol sa mga proseso ng dokumento at permit ng gobyerno sa Pilipinas. '
              'Gamitin ang mga bullet points para sa mga listahan, at i-bold ang mahahalagang salita gamit ang **bold**. '
              'Hatiin ang sagot sa maikling talata. Sumagot sa Filipino o English depende sa tanong ng user.',
        },
        ..._messages
            .skip(1)
            .map(
              (m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              },
            ),
      ];

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.1-8b-instant',
              'messages': messages,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        if (mounted) {
          setState(() {
            _messages.add(
              _ChatMessage(
                text: reply.trim(),
                isUser: false,
                time: _formatTime(DateTime.now()),
              ),
            );
          });
        }
      } else {
        debugPrint('Groq error: ${response.statusCode} ${response.body}');
        if (mounted)
          _addError('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Chatbot error: $e');
      if (mounted)
        _addError('Failed to connect. Please check your internet connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _addError(String msg) {
    setState(() {
      _messages.add(
        _ChatMessage(
          text: msg,
          isUser: false,
          time: _formatTime(DateTime.now()),
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
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
      backgroundColor: const Color.fromRGBO(208, 236, 252, 1),
      body: Column(
        children: [
          // --- SCROLLABLE CHAT AREA ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator();
                final msg = _messages[index];
                return msg.isUser
                    ? _buildUserMessage(msg.text, msg.time)
                    : _buildBotMessage(msg.text, msg.time, index);
              },
            ),
          ),

          // --- FIXED BOTTOM INPUT BAR ---
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black12, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Ask about your transaction...",
                        hintStyle: GoogleFonts.inter(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B73E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_outlined,
                      color: Colors.white,
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
            backgroundColor: const Color(0xFF1E65E2),
            child: ClipOval(
              child: Image.asset(
                'assets/chatbot_icon.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
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
                backgroundColor: const Color(0xFF1E65E2),
                child: ClipOval(
                  child: Image.asset(
                    'assets/chatbot_icon.png',
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
                    // ? Stack(
                    //     children: [
                    //       Container(
                    //         width: 11,
                    //         height: 11,
                    //         decoration: BoxDecoration(
                    //           color: Colors.grey,
                    //           shape: BoxShape.circle,
                    //           border: Border.all(
                    //             color: const Color.fromRGBO(208, 236, 252, 1),
                    //             width: 1.5,
                    //           ),
                    //         ),
                    //       ),
                    //       Positioned(
                    //         top: 4,
                    //         left: 4,
                    //         child: Container(
                    //           width: 3,
                    //           height: 3,
                    //           decoration: BoxDecoration(
                    //             color: const Color.fromRGBO(208, 236, 252, 1),
                    //             shape: BoxShape.circle,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   )
                    // // Container(
                    // //   width: 11,
                    // //   height: 11,
                    // //   decoration: BoxDecoration(
                    // //     color: const Color.fromARGB(255, 210, 54, 54),
                    // //     shape: BoxShape.circle,
                    // //     border: Border.all(
                    // //       color: const Color.fromRGBO(208, 236, 252, 1),
                    // //       width: 1.5,
                    // //     ),
                    // //   ),
                    // // )
                    // : Container(
                    //     width: 11,
                    //     height: 11,
                    //     decoration: BoxDecoration(
                    //       color: const Color(0xFF39D236),
                    //       shape: BoxShape.circle,
                    //       border: Border.all(
                    //         color: const Color.fromRGBO(208, 236, 252, 1),
                    //         width: 1.5,
                    //       ),
                    //     ),
                    //   ),
                    ? Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF39D236),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromRGBO(208, 236, 252, 1),
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
                                color: const Color.fromRGBO(208, 236, 252, 1),
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
                                color: const Color.fromRGBO(208, 236, 252, 1),
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
                const Text(
                  "DocsEase Bot",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black38,
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MarkdownBody(
                              data: text,
                              styleSheet: MarkdownStyleSheet(
                                p: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.black87,
                                ),
                                strong: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                listBullet: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black26,
                              ),
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
                              ? const Color(0xFF1E65E2).withOpacity(0.15)
                              : const Color.fromRGBO(190, 225, 252, 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _speakingIndex == index
                              ? Icons.stop
                              : Icons.volume_up_outlined,
                          size: 20,
                          color: const Color(0xFF1E65E2),
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
      padding: EdgeInsets.only(
        bottom: 18,
        left: MediaQuery.of(context).size.width * 0.25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
            decoration: const BoxDecoration(
              color: Color(0xFF3B73E0),
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
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: Colors.white60),
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

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
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
              decoration: const BoxDecoration(
                color: Color(0xFF1E65E2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
