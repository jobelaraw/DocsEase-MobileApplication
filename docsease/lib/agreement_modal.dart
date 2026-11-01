import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/legal_content.dart';

enum AgreementTab { terms, privacy }

/// Shows the Terms & Conditions / Privacy Policy sheet.
/// Returns true ONLY if the user taps "I Agree". Closing it, tapping
/// "Not now", the X, the barrier or the back button all return false.
class AgreementModal {
  AgreementModal._();

  /// Raw result:
  ///   true  = tapped "I Agree"
  ///   false = tapped "Not now"
  ///   null  = dismissed (tapped outside the dialog / back button)
  static Future<bool?> showForResult(
      BuildContext context, {
        AgreementTab initialTab = AgreementTab.terms,
      }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _AgreementDialog(initialTab: initialTab),
    );
  }

  /// Simple version: true only if the user tapped "I Agree".
  static Future<bool> show(
      BuildContext context, {
        AgreementTab initialTab = AgreementTab.terms,
      }) async {
    final result = await showForResult(context, initialTab: initialTab);
    return result == true;
  }
}

class _AgreementDialog extends StatefulWidget {
  final AgreementTab initialTab;
  const _AgreementDialog({required this.initialTab});

  @override
  State<_AgreementDialog> createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<_AgreementDialog> {
  static const Color _blue = Color.fromRGBO(59, 115, 224, 1.0);

  late int _index = widget.initialTab.index;
  final List<ScrollController> _controllers = [
    ScrollController(),
    ScrollController(),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? cs.primary : Colors.white;
    final heading = isDark ? cs.onPrimary : const Color(0xFF111827);
    final muted = isDark
        ? cs.onPrimary.withValues(alpha: 0.7)
        : const Color(0xFF6B7280);
    final accent = isDark ? cs.tertiary : _blue;
    final divider = isDark
        ? cs.onPrimary.withValues(alpha: 0.12)
        : const Color(0xFFE5E7EB);

    return Dialog(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Tabs ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: _buildTabs(cs, isDark),
            ),

            // ── Document ──
            Flexible(
              child: _buildDocument(
                _index,
                heading: heading,
                muted: muted,
                accent: accent,
                isDark: isDark,
                cs: cs,
              ),
            ),

            // ── Footer ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: divider)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'By tapping "I Agree", you confirm that you have read and '
                        'accept both the Terms & Conditions and the Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 11, height: 1.45, color: muted),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'I Agree',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Not now',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: muted,
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

  Widget _buildTabs(ColorScheme cs, bool isDark) {
    const labels = ['Terms & Conditions', 'Privacy Policy'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? cs.tertiary : const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final selected = _index == i;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _index = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? (isDark ? cs.surface : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? (isDark ? cs.onSurface : _blue)
                        : (isDark
                        ? cs.onPrimary.withValues(alpha: 0.7)
                        : const Color(0xFF6B7280)),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDocument(
      int i, {
        required Color heading,
        required Color muted,
        required Color accent,
        required bool isDark,
        required ColorScheme cs,
      }) {
    final isTerms = i == 0;
    final intro = isTerms ? LegalContent.termsIntro : LegalContent.privacyIntro;
    final sections = isTerms ? LegalContent.terms : LegalContent.privacy;
    final controller = _controllers[i];
    final bodyColor =
    isDark ? cs.onPrimary.withValues(alpha: 0.85) : const Color(0xFF374151);

    return Scrollbar(
      key: ValueKey('agreement_doc_$i'),
      controller: controller,
      thumbVisibility: true,
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        children: [
          Text(
            intro,
            style: GoogleFonts.inter(fontSize: 12.5, height: 1.55, color: muted),
          ),
          const SizedBox(height: 18),
          for (var n = 0; n < sections.length; n++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${n + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? cs.onPrimary : _blue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sections[n].heading,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: heading,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                sections[n].body,
                style: GoogleFonts.inter(
                    fontSize: 12.5, height: 1.6, color: bodyColor),
              ),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            'Version ${LegalContent.version} · Effective ${LegalContent.effectiveDate}',
            style: GoogleFonts.inter(fontSize: 11, color: muted),
          ),
        ],
      ),
    );
  }
}