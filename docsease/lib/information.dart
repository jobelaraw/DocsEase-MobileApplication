import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'info_model.dart';
import 'info_data.dart';

class InformationScreen extends StatefulWidget {
  final String title;
  const InformationScreen({super.key, required this.title});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ServiceDetail detail;

  final Color primaryBlue = const Color(0xFF2057CE);
  final Color lightBlueBg = const Color(0xFFE9F1F7);
  final Color accentBlue = const Color(0xFF03A9F4);

  @override
  void initState() {
    super.initState();
    detail = ServiceRepo.getDetail(widget.title);
    if (detail.tabs.length > 1) {
      _tabController = TabController(length: detail.tabs.length, vsync: this);
    }
  }

  @override
  void dispose() {
    if (detail.tabs.length > 1) _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(1),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: const SizedBox(
              width: 60,
              height: 60,
              child: Icon(
                Icons.arrow_back, 
                size: 30, 
                color: Colors.black),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Column(
        children: [
          if (detail.tabs.length > 1) _buildTabSwitcher(),
          Expanded(
            child: detail.tabs.length > 1
                ? TabBarView(
                    controller: _tabController,
                    children: detail.tabs
                        .map((tab) => _ContentList(
                              tab: tab,
                              detail: detail,
                              accentColor: accentBlue,
                            ))
                        .toList(),
                  )
                : _ContentList(
                    tab: detail.tabs.first,
                    detail: detail,
                    accentColor: accentBlue,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    if (detail.tabs.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color: lightBlueBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: primaryBlue,
        unselectedLabelColor: Colors.grey,
        labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold, 
            fontSize: 13, 
            height: 1.0),

        unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold, 
            fontSize: 13, 
            height: 1.0),
        tabs: detail.tabs.map((tab) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.center,
                child: Text(tab.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
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

  const _ContentList({
    required this.detail,
    required this.tab,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Text(detail.title,
            style:
                GoogleFonts.inter(
                  fontSize: 24, fontWeight: 
                  FontWeight.bold)),
        const SizedBox(height: 8),
        
        Text(detail.description,
            style: GoogleFonts.inter(
              fontSize: 11, 
              color: Colors.black54)),
        const SizedBox(height: 25),

        // Requirements Checklist Card
        _RequirementsCard(
            requirements: tab.requirements, 
            iconColor: accentColor),
        const SizedBox(height: 25),

        Text("Step-by-Step Guide",
            style:
                GoogleFonts.inter(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15)),
        const SizedBox(height: 17),

        // Steps
        ...tab.steps.asMap().entries.map((entry) => _StepItem(
              num: entry.key + 1,
              step: entry.value,
              isLast: entry.key == tab.steps.length - 1,
              accentColor: accentColor,
            )),

        const SizedBox(height: 5),
        _InfoGrid(
          detail: detail, 
          accentColor: accentColor),
        const SizedBox(height: 40),
        _ScheduleTile(),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _RequirementsCard extends StatefulWidget {
  final List<RequirementItem> requirements;
  final Color iconColor;

  const _RequirementsCard({
    required this.requirements,
    required this.iconColor,
  });

  @override
  State<_RequirementsCard> createState() => _RequirementsCardState();
}

class _RequirementsCardState extends State<_RequirementsCard> {
  late Map<String, bool> _checkedItems;

  @override
  void initState() {
    super.initState();
    _checkedItems = {for (var item in widget.requirements) item.title: false};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Icon(
              Icons.assignment_outlined, 
              color: widget.iconColor),
            const SizedBox(width: 8),
            
            Text(
              "Requirements Checklist",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        Text(
          "Requirements for ${_titleLabel}",
          style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
        const SizedBox(height: 12),

        ...widget.requirements.map((item) {
          final checked = _checkedItems[item.title] ?? false;
          return GestureDetector(
            onTap: () => setState(
                () => _checkedItems[item.title] = !checked),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Checkbox(
                    value: checked,
                    onChanged: (v) => setState(
                        () => _checkedItems[item.title] = v ?? false),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    activeColor: widget.iconColor,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: "Secure at:  ",
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.black54),
                            children: [
                              TextSpan(
                                text: item.secureAt,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF2057CE),
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

  String get _titleLabel => "New Business Application";
}

class _StepItem extends StatelessWidget {
  final int num;
  final ServiceStep step;
  final bool isLast;
  final Color accentColor;

  const _StepItem({
    required this.num,
    required this.step,
    required this.isLast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: num == 3 ? Colors.white : accentColor,
              child: Container(
                decoration: num == 3
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black, 
                          width: 2),
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  "$num",
                  style: TextStyle(
                    color: num == 3 ? Colors.black : Colors.white,
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
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.instruction,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // info boxes (Fee, Time, person)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _InfoBox(
                label: "Fee:", 
                value: step.fee)),
              const SizedBox(width: 8),

              Expanded(child: _InfoBox(
                label: "Processing Time:", 
                value: step.processingTime)),
              const SizedBox(width: 8),

              Expanded(
                child: _InfoBox(
                  label: "Person In-charge:",
                  value: step.personsInCharge.join('\n'),
                ),
              ),
            ],
          ),
        ),

        if (isLast) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, 
            children: [
              //For start navigation
              // SizedBox(
              //   height: 48,
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF2057CE),
              //       foregroundColor: Colors.white,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       elevation: 0,
              //       padding: const EdgeInsets.symmetric(horizontal: 20),
              //     ),
              //     child: const Text("Start Navigate",
              //         style: TextStyle(fontWeight: FontWeight.bold)),
              //   ),
              // ),
              // const SizedBox(width: 12),
              SizedBox(
                height: 45,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black87, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text("Mark As Done",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                        )
                    ),
                ),
              ),
            ],
          )
        ],
        const SizedBox(height: 30), 
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
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
          Expanded(
            child: _buildCard(
              Icons.location_on,
              "LOCATION",
              detail.location,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildContactCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF3B73E0), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(
              Icons.phone, 
              color: Color(0xFF3B73E0), 
              size: 28),
          ),
          const SizedBox(height: 8),
          
          Text("CONTACT",
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          Text(detail.contactPhone,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 4),

          Text(detail.contactEmail,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFB9D9EB),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("OFFICE SCHEDULE",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      letterSpacing: 0.5)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF52EC44),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text("OPEN NOW",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Monday - Friday",
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black)),
              Text("8:00 AM - 5:00 PM",
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}