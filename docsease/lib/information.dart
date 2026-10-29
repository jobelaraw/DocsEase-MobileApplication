import 'package:docsease/app_modals.dart';
import 'package:docsease/authentication.dart';
import 'package:docsease/main.dart';
import 'package:docsease/info_model.dart';
import 'package:docsease/app_localizations.dart';
import 'package:docsease/settings_provider.dart';
import 'package:docsease/information_additions.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class InformationScreen extends StatefulWidget {
  final ServiceDetail detail;

  const InformationScreen({
    super.key,
    required this.detail,
  });

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  final Color accentBlue = const Color(0xFF2458B8);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
  }

  @override
  void didUpdateWidget(covariant InformationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.detail != widget.detail) {
      _updateTabController();
    }
  }

  void _updateTabController() {
    final language =
        Provider.of<SettingsProvider>(context, listen: false).language;
    final tabs = widget.detail.getTabs(language);

    if (tabs.length <= 1) {
      _tabController?.dispose();
      _tabController = null;
      return;
    }

    if (_tabController == null ||
        _tabController!.length != tabs.length) {
      _tabController?.dispose();
      _tabController = TabController(
        length: tabs.length,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _updateProgress(
      List<String> requirements,
      List<String> steps,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.detail.serviceId.isEmpty) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('service_history')
        .doc(widget.detail.serviceId);

    final Map<String, dynamic> tabProgress = {};

    double overallProgress = 0;
    bool hasTrackableTabs = false;

    for (final tab in widget.detail.tabs) {
      final prefix = '${tab.name} : ';

      final tabRequirements = tab.requirements
          .map((item) => '$prefix${item.title}')
          .toList();

      final tabSteps = tab.steps
          .map((step) => '$prefix${step.title}')
          .toList();

      final tabTotal = tabRequirements.length + tabSteps.length;

      if (tabTotal == 0) continue;

      hasTrackableTabs = true;

      final tabDone =
          tabRequirements.where(requirements.contains).length +
              tabSteps.where(steps.contains).length;

      final progress = tabDone / tabTotal;
      final status = progress >= 1.0 ? 'Completed' : 'In Progress';

      tabProgress[tab.name] = {
        'progress': progress,
        'status': status,
        'completed_requirements':
        tabRequirements.where(requirements.contains).toList(),
        'completed_steps': tabSteps.where(steps.contains).toList(),
      };

      // Keep the highest progress as the overall service progress.
      overallProgress = max(overallProgress, progress);
    }

    final totalCompleted = requirements.length + steps.length;

    if (totalCompleted == 0) {
      await docRef.delete();
      return;
    }

    await docRef.set({
      'service_id': widget.detail.serviceId,
      'service_name': widget.detail.title,
      'checked_requirements': requirements,
      'completed_steps': steps,
      'tab_progress': tabProgress,
      'progress': hasTrackableTabs ? overallProgress : 0,
      'status': hasTrackableTabs && overallProgress >= 1.0
          ? 'Completed'
          : 'In Progress',
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _requireSignIn(BuildContext context) {
    RequireSignInModal.show(
      context,
      title: 'Information',
      onPrimary: () async {
        final rootNav = Navigator.of(context, rootNavigator: true);

        Hive.box('auth_box').put('continueGuest', false);
        rootNav.pop();

        rootNav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          ),
              (route) => false,
        );

        rootNav.push(
          MaterialPageRoute(
            builder: (context) => const Authentication(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final language = Provider.of<SettingsProvider>(context).language;
    final tabs = widget.detail.getTabs(language);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Stream<DocumentSnapshot>? historyStream =
    user != null && widget.detail.serviceId.isNotEmpty
        ? FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('service_history')
        .doc(widget.detail.serviceId)
        .snapshots()
        : null;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).colorScheme.surface
          : const Color(0xFFF7F9FC),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: historyStream,
          builder: (context, snapshot) {
            List<String> checkedRequirements = [];
            List<String> completedSteps = [];

            if (user != null &&
                snapshot.hasData &&
                snapshot.data!.exists) {
              final data =
              snapshot.data!.data() as Map<String, dynamic>;

              checkedRequirements = List<String>.from(
                data['checked_requirements'] ?? [],
              );

              completedSteps = List<String>.from(
                data['completed_steps'] ?? [],
              );
            }

            void handleToggleRequirement(
                String uniqueId,
                bool isChecked,
                ) {
              if (user == null) {
                _requireSignIn(context);
                return;
              }

              final updated = List<String>.from(checkedRequirements);

              if (isChecked) {
                if (!updated.contains(uniqueId)) {
                  updated.add(uniqueId);
                }
              } else {
                updated.remove(uniqueId);
              }

              _updateProgress(updated, completedSteps);
            }

            void handleToggleStep(
                String uniqueId,
                bool isDone,
                ) {
              if (user == null) {
                _requireSignIn(context);
                return;
              }

              final updated = List<String>.from(completedSteps);

              if (isDone) {
                if (!updated.contains(uniqueId)) {
                  updated.add(uniqueId);
                }
              } else {
                updated.remove(uniqueId);
              }

              _updateProgress(checkedRequirements, updated);
            }

            if (tabs.isEmpty) {
              return const Center(
                child: Text('No data available for this service.'),
              );
            }

            return Column(
              children: [
                if (tabs.length > 1) ...[
                  _buildTabSwitcher(tabs),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: tabs.length > 1
                      ? TabBarView(
                    controller: _tabController,
                    children: tabs.map((tab) {
                      return _ContentList(
                        key: ValueKey(
                          '${widget.detail.serviceId}_${tab.name}',
                        ),
                        tab: tab,
                        detail: widget.detail,
                        accentColor: accentBlue,
                        checkedReqs: checkedRequirements,
                        completedSteps: completedSteps,
                        onToggleReq: handleToggleRequirement,
                        onToggleStep: handleToggleStep,
                        language: language,
                      );
                    }).toList(),
                  )
                      : _ContentList(
                    tab: tabs.first,
                    detail: widget.detail,
                    accentColor: accentBlue,
                    checkedReqs: checkedRequirements,
                    completedSteps: completedSteps,
                    onToggleReq: handleToggleRequirement,
                    onToggleStep: handleToggleStep,
                    language: language,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabSwitcher(List<ServiceTab> tabs) {
    if (tabs.length <= 1 || _tabController == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest
            : const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedBuilder(
        animation: _tabController!,
        builder: (context, _) {
          return Row(
            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final selected = _tabController!.index == index;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  child: GestureDetector(
                    onTap: () {
                      _tabController!.animateTo(
                        index,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      constraints:
                      const BoxConstraints(minHeight: 46),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? cs.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(
                          color: isDark
                              ? cs.outline.withValues(alpha: 0.3)
                              : const Color(0xFFDDE4EF),
                        )
                            : null,
                      ),
                      child: Text(
                        tab.name.isEmpty ? 'Process' : tab.name,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? cs.onSurface
                              : cs.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE CONTENT
// -----------------------------------------------------------------------------

class _ContentList extends StatelessWidget {
  final ServiceDetail detail;
  final ServiceTab tab;
  final Color accentColor;
  final List<String> checkedReqs;
  final List<String> completedSteps;
  final Function(String, bool) onToggleReq;
  final Function(String, bool) onToggleStep;
  final String language;

  const _ContentList({
    super.key,
    required this.detail,
    required this.tab,
    required this.accentColor,
    required this.checkedReqs,
    required this.completedSteps,
    required this.onToggleReq,
    required this.onToggleStep,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    String tr(String key) =>
        AppLocalizations.translate(key, language);

    Widget sectionHeading({
      required IconData icon,
      required String title,
      String? subtitle,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? cs.primary
                    : const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 21,
                color: isDark
                    ? cs.onPrimary
                    : const Color(0xFF2458B8),
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
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: cs.onSurface,
                    ),
                  ),
                  if (subtitle != null &&
                      subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color:
                        cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    final description = detail.getDescription(language).trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          detail.getTitle(language),
          style: GoogleFonts.inter(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.25,
            letterSpacing: -0.5,
            color: cs.onSurface,
          ),
        ),

        if (description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.65,
              color: cs.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],

        const SizedBox(height: 22),

        TransactionSummaryCard(
          transactionType: tab.transactionType,
          whoMayAvail: tab.getWhoMayAvail(language).isNotEmpty
              ? tab.getWhoMayAvail(language)
              : tr('No information available.'),
          totalFee: tab.getTotalFee(language),
          totalTime: tab.getTotalProcessingTime(language),
          language: language,
        ),

        const SizedBox(height: 30),

        if (tab.requirements.isNotEmpty) ...[
          sectionHeading(
            icon: Icons.assignment_outlined,
            title: tr('Requirements Checklist'),
            subtitle: 'Prepare these documents before your visit.',
          ),

          _RequirementsCard(
            requirements: tab.requirements,
            iconColor: accentColor,
            title: detail.title,
            tabName: tab.name,
            checkedReqs: checkedReqs,
            onToggle: onToggleReq,
            language: language,
          ),

          const SizedBox(height: 30),
        ],

        if (tab.steps.isNotEmpty) ...[
          sectionHeading(
            icon: Icons.assignment_turned_in_outlined,
            title: tr('Step-by-Step Guide'),
            subtitle: 'Follow each step to complete your transaction.',
          ),


          ...tab.steps.asMap().entries.map(
                (entry) => _StepItem(
              num: entry.key + 1,
              step: entry.value,
              accentColor: accentColor,
              tabName: tab.name,
              completedSteps: completedSteps,
              canComplete: entry.key == 0 ||
                  completedSteps.contains(
                    '${tab.name} : ${tab.steps[entry.key - 1].title}',
                  ),
              isLast: entry.key == tab.steps.length - 1,
              onToggle: onToggleStep,
              language: language,
            ),
          ),

          const SizedBox(height: 12),
        ],

        sectionHeading(
          icon: Icons.location_city_outlined,
          title: tr('Office Information'),
          subtitle: 'Find the office and contact details.',
        ),

        _InfoGrid(
          detail: detail,
          accentColor: accentColor,
          language: language,
        ),

        const SizedBox(height: 24),


        _ScheduleTile(language: language),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// REQUIREMENTS CHECKLIST
// -----------------------------------------------------------------------------

class _RequirementsCard extends StatelessWidget {
  final List<RequirementItem> requirements;
  final Color iconColor;
  final String title;
  final String tabName;
  final List<String> checkedReqs;
  final Function(String, bool) onToggle;
  final String language;

  const _RequirementsCard({
    required this.requirements,
    required this.iconColor,
    required this.title,
    required this.tabName,
    required this.checkedReqs,
    required this.onToggle,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: requirements.map((item) {
        final uniqueKey = '$tabName : ${item.title}';
        final checked = checkedReqs.contains(uniqueKey);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: checked
                  ? iconColor.withValues(alpha: 0.55)
                  : cs.outlineVariant.withValues(alpha: 0.30),
              width: 0.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onToggle(uniqueKey, !checked),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: checked,
                    onChanged: (value) =>
                        onToggle(uniqueKey, value ?? false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    activeColor: iconColor,
                    materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          item.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: cs.onSurface,
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            text:
                            '${AppLocalizations.translate('Secure at', language)}: ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: cs.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            children: [
                              TextSpan(
                                text: item.secureAt.isNotEmpty
                                    ? item.secureAt
                                    : 'Not Applicable',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? cs.onSurface
                                      : const Color(0xFF2458B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// STEP-BY-STEP GUIDE
// -----------------------------------------------------------------------------


class _StepItem extends StatelessWidget {
  final int num;
  final ServiceStep step;
  final Color accentColor;
  final String tabName;
  final List<String> completedSteps;
  final bool canComplete;
  final bool isLast;
  final Function(String, bool) onToggle;
  final String language;

  const _StepItem({
    required this.num,
    required this.step,
    required this.accentColor,
    required this.tabName,
    required this.canComplete,
    required this.isLast,
    required this.completedSteps,
    required this.onToggle,
    required this.language,
  });

  void _startNavigation(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      RequireSignInModal.show(
        context,
        title: 'Information',
        onPrimary: () async {
          final rootNav =
          Navigator.of(context, rootNavigator: true);

          Hive.box('auth_box').put('continueGuest', false);
          rootNav.pop();

          rootNav.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const AuthWrapper(),
            ),
                (route) => false,
          );

          rootNav.push(
            MaterialPageRoute(
              builder: (context) => const Authentication(),
            ),
          );
        },
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.translate('Coming soon', language),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final uniqueKey = '$tabName : ${step.title}';
    final isDone = completedSteps.contains(uniqueKey);
    final hasNavigation = step.navigateTo.trim().isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Numbered circle and connecting timeline
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF2458B8)
                        : (isDark
                        ? cs.surfaceContainerHighest
                        : const Color(0xFFEAF1FF)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFF2458B8)
                          : cs.outlineVariant,
                    ),
                  ),
                  child: isDone
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                      : Text(
                    '$num',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? cs.onSurface
                          : const Color(0xFF2458B8),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF2458B8)
                            .withValues(alpha: 0.65)
                            : cs.outlineVariant
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // All step details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    step.instruction,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.6,
                      color:
                      cs.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  AgencyActions(
                    stepNumber: num,
                    actions: step.agencyActions,
                    language: language,
                  ),

                  if (step.onlineLink.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _OnlineLinkChip(
                      url: step.onlineLink.trim(),
                    ),
                  ],

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? cs.surfaceContainerLow
                          : const Color(0xFFF0F4FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _InfoBox(
                                label:
                                AppLocalizations.translate(
                                  'Fee',
                                  language,
                                ),
                                value: step.fee,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InfoBox(
                                label:
                                AppLocalizations.translate(
                                  'Processing Time',
                                  language,
                                ),
                                value: step.processingTime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _InfoBox(
                          label:
                          AppLocalizations.translate(
                            'Person In-charge',
                            language,
                          ),
                          value:
                          step.personsInCharge.join('\n'),
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),

                  if (step.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    NoteCallout(
                      text: step.notes.trim(),
                    ),
                  ],

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      if (hasNavigation) ...[
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _startNavigation(context),
                              icon: const Icon(
                                Icons.navigation_outlined,
                                size: 17,
                              ),
                              label: Text(
                                AppLocalizations.translate(
                                  'Navigate',
                                  language,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? cs.tertiary
                                    : const Color(0xFF2458B8),
                                foregroundColor: isDark
                                    ? cs.onTertiary
                                    : Colors.white,
                                elevation: 0,
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(11),
                                ),
                                textStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: isDone
                              ? ElevatedButton.icon(
                            onPressed: () =>
                                onToggle(uniqueKey, false),
                            icon: const Icon(
                              Icons.check,
                              size: 18,
                            ),
                            label: Text(
                              AppLocalizations.translate(
                                'Completed',
                                language,
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white
                                  : const Color(0xFF2458B8),
                              foregroundColor: isDark
                                  ? Colors.black
                                  : Colors.white,
                              elevation: 0,
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(11),
                              ),
                              textStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                              : OutlinedButton(
                            onPressed: () {
                              if (!canComplete) {
                                StepLockedModal.show(context);
                                return;
                              }
                              onToggle(uniqueKey, true);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.onSurface,
                              side: BorderSide(
                                color: cs.outline,
                                width: 1,
                              ),
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(11),
                              ),
                              textStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(
                              AppLocalizations.translate(
                                'Mark As Done',
                                language,
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// -----------------------------------------------------------------------------
// FEE / PROCESSING TIME / PERSON IN-CHARGE
// -----------------------------------------------------------------------------

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;

  const _InfoBox({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.trim().isNotEmpty ? value : 'N/A',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.45,
              color: isDark ? cs.onSurface : const Color(0xFF202938),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ONLINE LINK
// -----------------------------------------------------------------------------

class _OnlineLinkChip extends StatelessWidget {
  final String url;

  const _OnlineLinkChip({required this.url});

  Uri _resolvedUri() {
    final hasScheme =
    RegExp(r'^[a-zA-Z][a-zA-Z\d+\-.]*://').hasMatch(url);

    return Uri.parse(hasScheme ? url : 'https://$url');
  }

  Future<void> _openLink(BuildContext context) async {
    final uri = _resolvedUri();

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open the link.")),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open the link.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? cs.surfaceContainerHighest
          : const Color(0xFFFFF8E8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openLink(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? cs.outlineVariant
                  : const Color(0xFFEDE0BB),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.open_in_new,
                size: 18,
                color: Color(0xFF2458B8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  url,
                  softWrap: true,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: isDark
                        ? cs.onSurface
                        : const Color(0xFF2458B8),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// OFFICE INFORMATION
// -----------------------------------------------------------------------------

class _InfoGrid extends StatelessWidget {
  final ServiceDetail detail;
  final Color accentColor;
  final String language;

  const _InfoGrid({
    required this.detail,
    required this.accentColor,
    required this.language,
  });

  Uri _resolveWebsiteOrEmailUri(String raw) {
    final value = raw.trim();

    final looksLikeEmail = !value.contains('://') &&
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);

    if (looksLikeEmail) {
      return Uri(scheme: 'mailto', path: value);
    }

    final hasScheme =
    RegExp(r'^[a-zA-Z][a-zA-Z\d+\-.]*://').hasMatch(value);

    return Uri.parse(hasScheme ? value : 'https://$value');
  }

  Future<void> _openWebsiteOrEmail(
      BuildContext context,
      String raw,
      ) async {
    try {
      final launched = await launchUrl(
        _resolveWebsiteOrEmailUri(raw),
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open that.")),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open that.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = detail.location.trim().isNotEmpty
        ? detail.location
        : 'N/A';

    final phone = detail.contactPhone.trim().isNotEmpty
        ? detail.contactPhone
        : 'N/A';

    final website = detail.contactEmail.trim().isNotEmpty
        ? detail.contactEmail
        : 'N/A';


    Widget _buildContactCard(
        BuildContext context,
        String phone,
        String website,
        ) {
      final cs = Theme.of(context).colorScheme;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.10),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_mail_outlined,
                  size: 19,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.translate(
                      'CONTACT INFORMATION',
                      language,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact number
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: accentColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    phone,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Website or email
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.language_outlined,
                  size: 18,
                  color: accentColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: website != 'N/A'
                        ? () => _openWebsiteOrEmail(context, website)
                        : null,
                    child: Text(
                      website,
                      softWrap: true,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: website != 'N/A'
                            ? accentColor
                            : cs.onSurface,
                        decoration: website != 'N/A'
                            ? TextDecoration.underline
                            : null,
                      ),
                    ),
                  ),
                ),
                if (website != 'N/A')
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: accentColor,
                  ),
              ],
            ),
          ],
        ),
      );
    }


    return Column(
      children: [
        _buildCard(
          context,
          Icons.location_on_outlined,
          AppLocalizations.translate('LOCATION', language),
          location,
        ),
        const SizedBox(height: 12),
        _buildContactCard(context, phone, website),
      ],
    );

  }


  Widget _buildCard(
      BuildContext context,
      IconData icon,
      String label,
      String value, {
        VoidCallback? onTap,
      }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLink = onTap != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.10),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 19,
                      color: const Color(0xFF4778C7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    if (isLink)
                      Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: const Color(0xFF4778C7),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  value,
                  softWrap: true,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: isLink
                        ? const Color(0xFF4778C7)
                        : (isDark
                        ? cs.onSurface
                        : const Color(0xFF202938)),
                    decoration: isLink
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// -----------------------------------------------------------------------------
// OFFICE SCHEDULE
// -----------------------------------------------------------------------------



class _ScheduleTile extends StatelessWidget {
  final String language;

  const _ScheduleTile({required this.language});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get the current local date and time of the device.
    final now = DateTime.now();

    // DateTime.weekday: Monday = 1, Sunday = 7.
    final isWeekday = now.weekday >= DateTime.monday &&
        now.weekday <= DateTime.friday;

    // Open from 8:00 AM until 5:00 PM, Monday to Friday.
    final openingTime = DateTime(
      now.year,
      now.month,
      now.day,
      8,
    );

    final closingTime = DateTime(
      now.year,
      now.month,
      now.day,
      17,
    );

    final isOpen = isWeekday &&
        !now.isBefore(openingTime) &&
        now.isBefore(closingTime);

    final statusText = isOpen ? 'OPEN NOW' : 'CLOSED NOW';
    final statusColor = isOpen
        ? const Color(0xFF43E83E)
        : const Color(0xFFE53935);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerLow
            : const Color(0xFFE0EFF6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? cs.outlineVariant
              : const Color(0xFFC7D8E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.12 : 0.16,
            ),
            blurRadius: 7,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.translate(
                    'OFFICE SCHEDULE',
                    language,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? cs.onSurface
                        : const Color(0xFF59636A),
                  ),
                ),
              ),

              // Smaller status badge with dynamic text and color.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.translate(
                    statusText,
                    language,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isOpen ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Monday - Friday',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '8:00 AM - 5:00 PM',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

