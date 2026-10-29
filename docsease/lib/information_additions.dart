// information_additions.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/app_localizations.dart';

const Color _accent = Color(0xFF2458B8);

/// Summary at the top: type of transaction, who may avail, totals.

class TransactionSummaryCard extends StatefulWidget {
  final String transactionType;
  final String whoMayAvail;
  final String totalFee;
  final String totalTime;
  final String language;

  const TransactionSummaryCard({
    super.key,
    required this.transactionType,
    required this.whoMayAvail,
    required this.totalFee,
    required this.totalTime,
    required this.language,
  });

  @override
  State<TransactionSummaryCard> createState() =>
      _TransactionSummaryCardState();
}

class _TransactionSummaryCardState
    extends State<TransactionSummaryCard> {
  bool _isExpanded = false;

  String tr(String key) =>
      AppLocalizations.translate(key, widget.language);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final hasStats = widget.totalFee.trim().isNotEmpty ||
        widget.totalTime.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest
            : const Color(0xFFEAF1FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _accent.withValues(
            alpha: isDark ? 0.25 : 0.15,
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: _accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Summary',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _isExpanded
                              ? 'Hide transaction details'
                              : 'View fees, processing time, and details',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            height: 1.4,
                            color: cs.onSurface.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: cs.onSurface.withValues(alpha: 0.7),
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox(
              width: double.infinity,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 0, 16, 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: cs.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                    height: 1,
                  ),
                  const SizedBox(height: 14),

                  if (widget.transactionType.trim().isNotEmpty)
                    _row(
                      context,
                      Icons.swap_horiz,
                      tr('Type of Transaction'),
                      widget.transactionType,
                    ),

                  if (widget.transactionType.trim().isNotEmpty &&
                      widget.whoMayAvail.trim().isNotEmpty)
                    const SizedBox(height: 12),

                  if (widget.whoMayAvail.trim().isNotEmpty)
                    _row(
                      context,
                      Icons.people_outline,
                      tr('Who may avail'),
                      widget.whoMayAvail,
                    ),

                  if (hasStats) ...[
                    const SizedBox(height: 14),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                        children: [
                          if (widget.totalFee.trim().isNotEmpty)
                            Expanded(
                              child: _stat(
                                context,
                                Icons.payments_outlined,
                                tr('Total Fees'),
                                widget.totalFee,
                              ),
                            ),
                          if (widget.totalFee.trim().isNotEmpty &&
                              widget.totalTime.trim().isNotEmpty)
                            const SizedBox(width: 10),
                          if (widget.totalTime.trim().isNotEmpty)
                            Expanded(
                              child: _stat(
                                context,
                                Icons.schedule,
                                tr('Total Processing Time'),
                                widget.totalTime,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );


  }

  Widget _row(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 3),

              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: cs.onSurface,
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    final cs = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surface.withValues(alpha: 0.65)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _accent.withValues(
            alpha: isDark ? 0.20 : 0.10,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: _accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}


/// "What the agency does" list shown inside each step.
/// Numbering mirrors the charter: 1, 1.1, 1.2 ...
class AgencyActions extends StatelessWidget {
  final int stepNumber;
  final List<String> actions;
  final String language;

  const AgencyActions({
    super.key,
    required this.stepNumber,
    required this.actions,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: isDark ? 0.16 : 0.07),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.translate('What the Office Does', language),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: isDark ? const Color(0xFF8FB5FF) : _accent,
                ),
              ),
              const SizedBox(height: 8),
              ...actions.asMap().entries.map((e) {
                final label = e.key == 0
                    ? '$stepNumber'
                    : '$stepNumber.${e.key}';

                return Padding(
                  padding: EdgeInsets.only(top: e.key == 0 ? 0 : 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.value,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Highlighted footnote / important reminder.
class NoteCallout extends StatelessWidget {
  final String text;

  const NoteCallout({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withValues(alpha: 0.12)
            : const Color(0xFFFFF7E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.amber.withValues(alpha: 0.3)
              : const Color(0xFFF0E4BE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: isDark ? Colors.amber : const Color(0xFF9A6B00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
