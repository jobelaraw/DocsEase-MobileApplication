import 'package:docsease/app_localizations.dart';
import 'package:docsease/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Colors for light / dark mode ───
class _Palette {
  final Color card, border, accent, text, iconBg, divider, dotInactive;

  const _Palette({
    required this.card,
    required this.border,
    required this.accent,
    required this.text,
    required this.iconBg,
    required this.divider,
    required this.dotInactive,
  });

  factory _Palette.of(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      return _Palette(
        card: theme.colorScheme.primary,
        border: Colors.white24,
        accent: const Color(0xFF93C5FD),
        text: Colors.white,
        iconBg: const Color(0xFFDBEAFE),
        divider: Colors.white24,
        dotInactive: Colors.white24,
      );
    }
    return const _Palette(
      card: Color(0xFFF7FBFF),
      border: Color(0xFF7FA6F0),
      accent: Color(0xFF3B73E0),
      text: Colors.black87,
      iconBg: Color(0xFFDBEAFE),
      divider: Colors.black54,
      dotInactive: Color(0xFFD0D0D0),
    );
  }
}

class _Offer {
  final String title;
  final String description;
  final String asset;

  const _Offer(this.title, this.description, this.asset);
}

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).language;
    String tr(String key) => AppLocalizations.translate(key, lang);
    final p = _Palette.of(context);

    final offers = <_Offer>[
      _Offer(
        tr('Requirements & Procedures'),
        tr(
          'Provides clear lists of prerequisites, and a detailed checklist of requirements and step-by-step procedures for each municipal service at Biñan City Hall, with built-in local offline caching so you can view all transaction guides even without an internet connection.',        ),
        'assets/req.png',
      ),
      _Offer(
        tr('AI Chatbot Assistance'),
        tr(
          'Features an intelligent chatbot specialized in answering inquiries about Biñan City Hall document processes, offering quick-access buttons, speech-to-text accessibility, and a complete chat history manager that lets you search, add, delete, and view previous conversations instantly.',        ),
        'assets/ai.png',
      ),
      _Offer(
        tr('AR Indoor Navigation'),
        tr(
          'Helps users navigate inside Biñan City Hall by scanning wall-mounted QR calibration codes and following augmented reality directional pathways to offices and windows, complete with an interactive 2D map fallback interface that automatically activates for smartphones lacking AR hardware support.',        ),
        'assets/ar.png',
      ),
      _Offer(
        tr('Progress Tracker'),
        tr(
          'Allows you to monitor your active municipal applications and multi-service transactions simultaneously through real-time status updates, manual step-by-step digital checklists, progress percentages, and complete archiving securely accessible inside your profile\'s Service History.',        ),
        'assets/progress.png',
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Slider card (logo + title  <->  description) ───
            _buildSlider(p, tr),
            const SizedBox(height: 12),
            _buildDots(p),
            const SizedBox(height: 28),

            // ─── Mission ───
            _SectionCard(
              p: p,
              child: _Collapsible(
                chevronColor: p.text,
                header: Text(
                  tr('Our Mission'),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: p.accent,
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    tr(
                      'To empower the citizens of Biñan by providing a reliable mobile guide that delivers clear requirements, step-by-step procedures, intelligent chatbot assistance, and office navigation to simplify the preparation of public service transactions.',
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: p.text),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ─── Vision ───
            _SectionCard(
              p: p,
              child: _Collapsible(
                chevronColor: p.text,
                header: Text(
                  tr('Our Vision'),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: p.accent,
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    tr(
                      'A well-informed and digitally supported community where every citizen can navigate Biñan City Hall services with clarity, confidence, and ease.',
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: p.text),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ─── What GaBayan Offers ───
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: _offersTitle(tr('What GaBayan Offers'), p),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              p: p,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  for (int i = 0; i < offers.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _Collapsible(
                        initiallyExpanded: false,
                        chevronColor: p.text,
                        header: Row(
                          children: [
                            _IconBox(asset: offers[i].asset, p: p),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                offers[i].title,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: p.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                        body: Padding(
                          padding: const EdgeInsets.only(top: 10, left: 2),
                          child: Text(
                            offers[i].description,
                            style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: p.text),
                          ),
                        ),
                      ),
                    ),
                    if (i != offers.length - 1)
                      Divider(height: 1, thickness: 0.5, color: p.divider),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

// ─── Contact Us ───
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                tr('Contact Us'),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: p.text,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              p: p,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  // ─── EMAIL (Clickable) ───
                  InkWell(
                    onTap: () async {
                      final Uri emailLaunchUri = Uri(scheme: 'mailto', path: 'gabayan.noreply@gmail.com');
                      if (await canLaunchUrl(emailLaunchUri)) {
                        await launchUrl(emailLaunchUri);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          _IconBox(
                            asset: 'assets/email_icon.png',
                            p: p,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              'gabayan.noreply@gmail.com',
                              style: GoogleFonts.inter(fontSize: 14, color: p.text),
                            ),
                          ),
                          // Arrow Icon para sa Email
                          Icon(Icons.chevron_right, color: p.text),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, thickness: 0.8, color: p.divider),
                  // ─── PHONE NUMBER (Clickable) ───
                  InkWell(
                    onTap: () async {
                      final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '09949634252'); // Tinanggal ang spaces sa number
                      if (await canLaunchUrl(phoneLaunchUri)) {
                        await launchUrl(phoneLaunchUri);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          _IconBox(
                            asset: 'assets/contact_icon.png',
                            p: p,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              '0994 963 4252',
                              style: GoogleFonts.inter(fontSize: 14, color: p.text),
                            ),
                          ),
                          // Arrow Icon para sa Phone
                          Icon(Icons.chevron_right, color: p.text),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slider: page 0 = logo + title, page 1 = description text
  Widget _buildSlider(_Palette p, String Function(String) tr) {
    final height = MediaQuery.textScalerOf(context).scale(200);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            // Page 1: logo + title
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF1B3A6B), width: 1),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'GaBayan',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: p.accent,
                  ),
                ),
                Text(
                  tr('version 1.0'),
                  style: GoogleFonts.inter(fontSize: 11, color: p.accent),
                ),
              ],
            ),

            // Page 2: app description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Text(
                  tr(
                    'A mobile assistant designed to help citizens easily navigate government services by providing clear requirement lists, step-by-step procedures, an AI chatbot, and indoor navigation for Biñan City Hall, empowering users with accurate guidance for their local government transactions.',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, height: 1.35, color: p.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots(_Palette p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = _page == i;
        return GestureDetector(
          onTap: () => _goToPage(i),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: active ? 10 : 8,
              height: active ? 10 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? p.accent : p.dotInactive,
              ),
            ),
          ),
        );
      }),
    );
  }

  // Title where the word "GaBayan" is blue (works for English and Filipino)
  Widget _offersTitle(String text, _Palette p) {
    final base = GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: p.text);
    final parts = text.split('GaBayan');
    if (parts.length != 2) return Text(text, style: base);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: parts[0]),
          TextSpan(text: 'GaBayan', style: TextStyle(color: p.accent)),
          TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}

// ─── Rounded bordered card ───
class _SectionCard extends StatelessWidget {
  final _Palette p;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.p,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border, width: 1),
      ),
      child: child,
    );
  }
}

// ─── Small square icon holder (png goes here later) ───
class _IconBox extends StatelessWidget {
  final String asset;
  final _Palette p;

  const _IconBox({required this.asset, required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: p.iconBg, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          asset,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : p.text,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Icon(
                Icons.broken_image,
                size: 24,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : p.text,
              ),
        ),
      ),
    );
  }
}

// ─── Smooth collapsible (header + chevron, animated body) ───
class _Collapsible extends StatefulWidget {
  final Widget header;
  final Widget body;
  final Color chevronColor;
  final bool initiallyExpanded;

  const _Collapsible({
    required this.header,
    required this.body,
    required this.chevronColor,
    this.initiallyExpanded = true,
  });

  @override
  State<_Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<_Collapsible> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  late final Animation<double> _chevronTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.initiallyExpanded ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // Same as the design: open = arrow down, closed = arrow up
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
            children: [
              Expanded(child: widget.header),
              RotationTransition(
                turns: _chevronTurns,
                child: Icon(Icons.arrow_drop_down, size: 32, color: widget.chevronColor),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _anim,
          axisAlignment: -1.0,
          child: FadeTransition(opacity: _anim, child: widget.body),
        ),
      ],
    );
  }
}