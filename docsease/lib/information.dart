import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:docsease/info_model.dart';

class InformationScreen extends StatefulWidget {
  final ServiceDetail detail;
  const InformationScreen({super.key, required this.detail});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Color get primaryBlue => Theme.of(context).colorScheme.primary;
  final Color lightBlueBg = const Color(0xFFE9F1F7);
  final Color accentBlue = const Color(0xFF03A9F4);

  @override
  void initState() {
    super.initState();
    if (widget.detail.tabs.length > 1) {
      _tabController = TabController(length: widget.detail.tabs.length, vsync: this);
    }
  }

  @override
  void dispose() {
    if (widget.detail.tabs.length > 1) _tabController.dispose();
    super.dispose();
  }

  // Calculates overall progress and pushes it to Firestore
  void _updateProgress(List<String> reqs, List<String> steps) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.detail.serviceId.isEmpty) return;

    int totalReqs = 0;
    int totalSteps = 0;
    for (var tab in widget.detail.tabs) {
      totalReqs += tab.requirements.length;
      totalSteps += tab.steps.length;
    }

    int total = totalReqs + totalSteps;
    int completed = reqs.length + steps.length;
    double progress = total == 0 ? 0.0 : (completed / total);
    String status = progress >= 1.0 ? "Completed" : "In Progress";

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('service_history')
        .doc(widget.detail.serviceId);

    // If everything is unchecked, remove the document entirely
    if (completed == 0) {
      await docRef.delete();
    } else {
      await docRef.set({
        'service_id': widget.detail.serviceId,
        'service_name': widget.detail.title,
        'checked_requirements': reqs,
        'completed_steps': steps,
        'progress': progress,
        'status': status,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Fallback if user is not logged in
    if (user == null) return const Scaffold(body: Center(child: Text("Please log in first.")));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('service_history')
            .doc(widget.detail.serviceId)
            .snapshots(),
        builder: (context, snapshot) {
          List<String> checkedReqs = [];
          List<String> completedSteps = [];

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            checkedReqs = List<String>.from(data['checked_requirements'] ?? []);
            completedSteps = List<String>.from(data['completed_steps'] ?? []);
          }

          void handleToggleReq(String uniqueId, bool isChecked) {
            List<String> newReqs = List.from(checkedReqs);
            if (isChecked)
              newReqs.add(uniqueId);
            else
              newReqs.remove(uniqueId);
            _updateProgress(newReqs, completedSteps);
          }

          void handleToggleStep(String uniqueId, bool isDone) {
            List<String> newSteps = List.from(completedSteps);
            if (isDone)
              newSteps.add(uniqueId);
            else
              newSteps.remove(uniqueId);
            _updateProgress(checkedReqs, newSteps);
          }

          return Column(
            children: [
              if (widget.detail.tabs.length > 1) _buildTabSwitcher(),
              Expanded(
                child: widget.detail.tabs.isEmpty
                    ? const Center(child: Text("No data available for this service."))
                    : widget.detail.tabs.length > 1
                    ? TabBarView(
                        controller: _tabController,
                        children: widget.detail.tabs
                            .map(
                              (tab) => _ContentList(
                                tab: tab,
                                detail: widget.detail,
                                accentColor: accentBlue,
                                checkedReqs: checkedReqs,
                                completedSteps: completedSteps,
                                onToggleReq: handleToggleReq,
                                onToggleStep: handleToggleStep,
                              ),
                            )
                            .toList(),
                      )
                    : _ContentList(
                        tab: widget.detail.tabs.first,
                        detail: widget.detail,
                        accentColor: accentBlue,
                        checkedReqs: checkedReqs,
                        completedSteps: completedSteps,
                        onToggleReq: handleToggleReq,
                        onToggleStep: handleToggleStep,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabSwitcher() {
    if (widget.detail.tabs.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiary, borderRadius: BorderRadius.circular(15)),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Theme.of(context).brightness == Brightness.dark 
        ? Theme.of(context).colorScheme.onPrimary
        : primaryBlue,
        unselectedLabelColor: Theme.of(context).brightness == Brightness.dark 
        ? Theme.of(context).colorScheme.onPrimary
        : Colors.grey,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, height: 1.0),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          height: 1.0,
        ),
        tabs: widget.detail.tabs.map((tab) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  tab.name.isEmpty ? "Process" : tab.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ContentList extends StatelessWidget {
  final ServiceDetail detail;
  final ServiceTab tab;
  final Color accentColor;
  final List<String> checkedReqs;
  final List<String> completedSteps;
  final Function(String, bool) onToggleReq;
  final Function(String, bool) onToggleStep;

  const _ContentList({
    required this.detail,
    required this.tab,
    required this.accentColor,
    required this.checkedReqs,
    required this.completedSteps,
    required this.onToggleReq,
    required this.onToggleStep,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(30),
      children: [
        Text(detail.title, style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Text(
          detail.description.isNotEmpty ? detail.description : "No description available.",
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 25),

        if (tab.requirements.isNotEmpty) ...[
          _RequirementsCard(
            requirements: tab.requirements,
            iconColor: accentColor,
            title: detail.title,
            tabName: tab.name,
            checkedReqs: checkedReqs,
            onToggle: onToggleReq,
          ),
          const SizedBox(height: 30),
        ],

        if (tab.steps.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.assignment_turned_in_outlined, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                tab.steps.length != 1
                    ? "Step-by-Step Guide (1-${tab.steps.length})"
                    : "Step-by-Step Guide (1)",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...tab.steps.asMap().entries.map(
            (entry) => _StepItem(
              num: entry.key + 1,
              step: entry.value,
              accentColor: accentColor,
              tabName: tab.name,
              completedSteps: completedSteps,
              onToggle: onToggleStep,
            ),
          ),
        ],

        const SizedBox(height: 10),
        _InfoGrid(detail: detail, accentColor: accentColor),
        const SizedBox(height: 30),
        _ScheduleTile(),
      ],
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  final List<RequirementItem> requirements;
  final Color iconColor;
  final String title;
  final String tabName;
  final List<String> checkedReqs;
  final Function(String, bool) onToggle;

  const _RequirementsCard({
    required this.requirements,
    required this.iconColor,
    required this.title,
    required this.tabName,
    required this.checkedReqs,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_outlined, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              "Requirements Checklist",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 15),

        ...requirements.map((item) {
          // Creates a unique key so identical requirement names on different tabs don't clash
          final uniqueKey = "$tabName : ${item.title}";
          final checked = checkedReqs.contains(uniqueKey);

          return GestureDetector(
            onTap: () => onToggle(uniqueKey, !checked),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: checked,
                    onChanged: (v) => onToggle(uniqueKey, v ?? false),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    activeColor: iconColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 50)),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: "Secure at:  ",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            children: [
                              TextSpan(
                                text: item.secureAt.isNotEmpty ? item.secureAt : "Not Applicable",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
                                      : const Color(0xFF3B73E0),
                                  fontWeight: FontWeight.w500,
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
          );
        }),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int num;
  final ServiceStep step;
  final Color accentColor;
  final String tabName;
  final List<String> completedSteps;
  final Function(String, bool) onToggle;

  const _StepItem({
    required this.num,
    required this.step,
    required this.accentColor,
    required this.tabName,
    required this.completedSteps,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Unique key logic to prevent bleeding states across tabs
    final uniqueKey = "$tabName : ${step.title}";
    bool isDone = completedSteps.contains(uniqueKey);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isDone ? accentColor : Colors.white,
              child: Container(
                decoration: isDone
                    ? null
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                alignment: Alignment.center,
                child: Text(
                  "$num",
                  style: TextStyle(
                    color: isDone ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.instruction,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
            : const Color.fromARGB(255, 255, 255, 255)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _InfoBox(label: "Fee:", value: step.fee),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoBox(label: "Processing Time:", value: step.processingTime),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _InfoBox(label: "Person In-charge:", value: step.personsInCharge.join('\n')),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Start Navigate button
            /* SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.tertiary
                  : const Color(0xFF2057CE),
                  foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text("Start Navigate",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ), */
            
            // Mark As Done button
            SizedBox(
              height: 45,
              child: isDone
                  ? ElevatedButton(
                      onPressed: () => onToggle(uniqueKey, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.tertiary
                        : const Color(0xFF2057CE),
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onPrimary
                        : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check, size: 18),
                          SizedBox(width: 8),
                          Text("Completed", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () => onToggle(uniqueKey, true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text(
                        "Mark As Done",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.brightnessOf(  context) == Brightness.dark
            ? Theme.of(context).colorScheme.primary
            :const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.brightnessOf(  context) == Brightness.dark
            ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1)
            : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.brightnessOf(context) == Brightness.dark
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
              : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isNotEmpty ? value : "N/A",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.brightnessOf(context) == Brightness.dark
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.black87,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final ServiceDetail detail;
  final Color accentColor;

  const _InfoGrid({required this.detail, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildCard(context, Icons.location_on, "LOCATION", detail.location)),
          const SizedBox(width: 15),
          Expanded(child: _buildContactCard(context)),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String label, String value) {
    return Material(
      borderRadius: BorderRadius.circular(25),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Theme.of(context).colorScheme.primary 
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Theme.brightnessOf(  context) == Brightness.dark
            ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1)
            : Colors.grey.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Icon(icon, color: const Color(0xFF3B73E0), size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
                        : Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(25),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
           color: Theme.of(context).brightness == Brightness.dark 
              ? Theme.of(context).colorScheme.primary 
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Theme.brightnessOf(  context) == Brightness.dark
            ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1)
            : Colors.grey.shade100,
            ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Icon(Icons.phone, color: Color(0xFF3B73E0), size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  "CONTACT",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              detail.contactPhone.isNotEmpty ? detail.contactPhone : "N/A",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail.contactEmail.isNotEmpty ? detail.contactEmail : "N/A",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(25),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Theme.of(context).colorScheme.primary
          : const Color.fromRGBO(185, 217, 235, 0.45),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "OFFICE SCHEDULE",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF52EC44),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "OPEN NOW",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Monday - Friday",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black,
                  ),
                ),
                Text(
                  "8:00 AM - 5:00 PM",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
