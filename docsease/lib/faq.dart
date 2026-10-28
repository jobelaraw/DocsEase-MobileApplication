import 'package:docsease/app_localizations.dart';
import 'package:docsease/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

// ─── ADD YOUR FAQs HERE (the list scrolls, so add as many as you want) ───
const List<_Faq> _faqs = [
// ─── GENERAL APP & LIMITATIONS ───
  _Faq(
    'Can I submit my documents and pay fees through the app?',
    'No. GaBayan is strictly an informative guide and navigation tool. All document submissions, processing, and payments must be done physically at the respective offices in Biñan City Hall.',
  ),
  _Faq(
    'Can I schedule a City Hall appointment using GaBayan?',
    'No, the app does not support online appointment scheduling at this time. It is designed to provide you with the exact prerequisites and steps you need to prepare before your walk-in visit.',
  ),
  _Faq(
    'Is GaBayan used by LGU staff to process my papers?',
    'No. GaBayan is designed exclusively for citizens (users) to guide them through their municipal transactions. City Hall staff do not use this app to process or approve your documents.',
  ),
  _Faq(
    'What should I do if the document requirements listed in GaBayan differ from what the City Hall staff is asking for?',
    'While we strive to keep GaBayan updated, local government policies may change without prior notice. Always defer to the final instructions of the City Hall evaluating officer. You can also report the discrepancy to us via the "Contact Us" section so we can update the app.',
  ),

// ─── ACCOUNT MANAGEMENT & SECURITY ───
  _Faq(
    'How is continuing as a "Guest" different from creating a registered account?',
    'As a guest user, you can browse all municipal services, read procedures, and adjust visual settings. However, for security and data privacy, guests cannot check off requirement boxes, use the AR Indoor Navigation, chat with the GaBayan Bot, or receive push notifications. You need to create an account to unlock these interactive features.',
  ),
  _Faq(
    'How do I edit my profile information?',
    'You can update your personal details by going to the Profile screen and tapping the "Edit Profile" button. Make sure to save your changes after updating.',
  ),
  _Faq(
    'What happens if I forget my account password?',
    'You can tap "Forgot Password" on the login screen. We will send a secure link to your registered email address so you can reset your password safely.',
  ),
  _Faq(
    'How long will my account be locked if I enter the wrong password multiple times?',
    'For your security, if you enter an incorrect password five (5) consecutive times, your account will be temporarily locked for exactly 10 minutes. You must wait for the cooldown timer to finish before attempting to sign in again.',
  ),
  _Faq(
    'How does the app protect my personal data if I forget to log out on a shared device?',
    'GaBayan includes an automatic session timeout feature. If the application is left completely idle with no screen interactions for 15 minutes, the system will automatically log you out and return you to the Sign In screen to protect your privacy.',
  ),
  _Faq(
    'Are my previous transactions and chatbot conversations visible to the Biñan City Hall staff?',
    'No. Your Progress Tracker, Service History, and chatbot conversations are private and securely stored in your personal account. City Hall staff do not have access to your GaBayan profile data.',
  ),
  _Faq(
    'Can I delete my GaBayan account?',
    'Yes, you can permanently delete your account in the Profile settings. Please note that deleting your account will also permanently erase your saved service history and progress trackers.',
  ),

// ─── PROGRESS TRACKER & SERVICE HISTORY ───
  _Faq(
    'Does the Progress Tracker automatically update when I finish a step at City Hall?',
    'No. The Progress Tracker serves as your personal digital checklist. You need to manually check off the steps on your phone as you complete them to monitor your own progress.',
  ),
  _Faq(
    'Can I track multiple services at the same time?',
    'Yes! You can add and monitor multiple active transactions simultaneously. All of them will be saved and accessible in your profile\'s Service History.',
  ),

// ─── AR INDOOR NAVIGATION ───
  _Faq(
    'How do I calibrate my phone for AR Indoor Navigation?',
    'First, scan one of the designated QR codes posted on the walls or posts inside Biñan City Hall to set your starting location. After scanning, hold your phone upright and slowly pan it left and right so the app can recognize the floor and walls.',
  ),
  _Faq(
    'Do I need internet access to use the AR Indoor Navigation?',
    'Yes, a stable internet connection and camera permission are required to accurately load the map and AR pathways inside Biñan City Hall.',
  ),
  _Faq(
    'How do I know if I am walking in the right direction?',
    'Follow the on-screen digital arrows pointing toward your destination. If you stray from the path, the app will automatically recalculate and guide you back to the correct route.',
  ),
  _Faq(
    'How do I navigate City Hall if my smartphone does not support Augmented Reality (AR) technology?',
    'If your device lacks AR hardware support, GaBayan will gracefully detect this and automatically switch to a 2D Map fallback interface. This interactive top-down map will still display your current location pin and draw a clear path to your destination office.',
  ),
  _Faq(
    'How do I switch from the AR camera view to a standard map if I prefer looking at a floor plan?',
    'While in AR Navigation mode, you will see a circular minimap on your screen. Tapping this minimap will expand it into a full interactive 2D map view, allowing you to easily browse rooms and target destinations without needing to point your camera.',
  ),

// ─── AI CHATBOT ───
  _Faq(
    'What kind of questions can the AI Chatbot answer?',
    'The chatbot is specifically trained to answer inquiries about Biñan City Hall services, required documents, and step-by-step procedures for local public service transactions.',
  ),
  _Faq(
    'Am I talking to a real City Hall employee in the chatbot?',
    'No. The chatbot is an automated AI assistant programmed with Biñan City Hall\'s public service guidelines. It does not connect you to a live person or LGU staff.',
  ),
];

// Set to false if you want every FAQ closed when the screen opens
const bool _startExpanded = false;

class FaqScreen extends StatefulWidget {
  /// Called after the FAQ closes, to open the side menu (hamburger button).
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).language;
    String tr(String key) => AppLocalizations.translate(key, lang);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    final accent = isDark ? const Color(0xFF93C5FD) : const Color(0xFF3B73E0);
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? scheme.primary : const Color(0xFFF7FBFF);
    final borderColor = isDark ? Colors.white24 : const Color(0xFF7FA6F0);
    final iconBg = const Color(0xFFDBEAFE);
    final dividerColor = isDark ? Colors.white24 : Colors.black45;

    // Search works on the translated text, so it also works in Filipino
    final q = _query.trim().toLowerCase();
    final results = _faqs.where((f) {
      if (q.isEmpty) return true;
      return tr(f.question).toLowerCase().contains(q) || tr(f.answer).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // The whole page scrolls, so any number of FAQs is fine
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
        child: Column(
          children: [
            Text(
              tr('How can we help you?'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: accent),
            ),
            const SizedBox(height: 20),

            // ─── Search bar ───
            Container(
              height: 46,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: isDark ? scheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade500, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.inter(fontSize: 14, color: textColor),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: tr('search question here'),
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, size: 28, color: textColor),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                    icon: Icon(Icons.close, size: 20, color: textColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ─── FAQ list ───
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  tr('No questions found.'),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < results.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _FaqItem(
                          key: ValueKey(results[i].question),
                          question: tr(results[i].question),
                          answer: tr(results[i].answer),
                          answerLabel: tr('Answer:'),
                          textColor: textColor,
                          iconBg: iconBg,
                        ),
                      ),
                      if (i != results.length - 1)
                        Divider(height: 1, thickness: 0.5, color: dividerColor),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── One FAQ row with smooth open / close ───
class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final String answerLabel;
  final Color textColor;
  final Color iconBg;

  const _FaqItem({
    super.key,
    required this.question,
    required this.answer,
    required this.answerLabel,
    required this.textColor,
    required this.iconBg,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  late final Animation<double> _chevronTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _startExpanded ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // open = arrow down, closed = arrow up (same as About screen)
    _chevronTurns = Tween<double>(begin: 0.5, end: 0.0).animate(_anim);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.status == AnimationStatus.completed ||
        _controller.status == AnimationStatus.forward) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '?',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : widget.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.question,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                ),
              ),
              RotationTransition(
                turns: _chevronTurns,
                child: Icon(Icons.arrow_drop_down, size: 32, color: widget.textColor),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _anim,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _anim,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 2, right: 2),
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.inter(fontSize: 12.5, height: 1.4, color: widget.textColor),
                  children: [
                    TextSpan(
                      text: '${widget.answerLabel} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.answer),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}