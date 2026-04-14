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

class _InformationScreenState extends State<InformationScreen> with SingleTickerProviderStateMixin {
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
          _tabController = TabController(
            length: detail.tabs.length,
            vsync: this,
          );
        }
      }

  @override
    void dispose() {
      if (detail.tabs.length > 1) {
        _tabController.dispose();
      }
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
              color: Colors.black,
            ),
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
                  children: detail.tabs.map((tab) {
                    return _ContentList(
                      tab: tab,
                      detail: detail,
                      accentColor: accentBlue,
                    );
                  }).toList(),
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
  if (detail.tabs.length <= 1) {
    return const SizedBox.shrink(); // hides tab completely
  }

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
        )
      ],
    ),
    labelColor: primaryBlue,
    unselectedLabelColor: Colors.grey,
    labelStyle: GoogleFonts.inter(
      fontWeight: FontWeight.bold, 
      fontSize: 13, 
      height: 1.0, 
    ),
    unselectedLabelStyle: GoogleFonts.inter(
      fontWeight: FontWeight.bold, 
      fontSize: 13,
      height: 1.0,
    ),
    tabs: detail.tabs.map((tab) {
      return Tab(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              tab.name,
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
        //text style
        Text(detail.title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(detail.description, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 25),
        
        _RequirementsCard(requirements: tab.requirements, iconColor: accentColor),
        const SizedBox(height: 25),
        
        Text("Step-by-Step Guide", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 17),
        
        // loop builds each step sa info_data.dart
        ...tab.steps.asMap().entries.map((entry) => _StepItem(
              num: entry.key + 1,
              step: entry.value,
              isLast: entry.key == tab.steps.length - 1,
              accentColor: accentColor,
            )),
            
        const SizedBox(height: 5),
        _InfoGrid(detail: detail, accentColor: accentColor),
        const SizedBox(height: 40),
        _ScheduleTile(),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _RequirementsCard extends StatefulWidget {
  final List<String> requirements;
  final Color iconColor;

  const _RequirementsCard({required this.requirements, required this.iconColor});

  @override
  State<_RequirementsCard> createState() => _RequirementsCardState();
}

class _RequirementsCardState extends State<_RequirementsCard> {
  // Dito natin ise-save kung ano ang mga naka-check
  late Map<String, bool> _checkedItems;

  @override
  void initState() {
    super.initState();
    // unchecked
    _checkedItems = {for (var item in widget.requirements) item: false};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10)],
      ),
      
      child: Column(
        children: [
          Row(children: [
            Icon(Icons.assignment_outlined, color: widget.iconColor),
            const SizedBox(width: 10),
            Text("Requirements Checklist", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 10),
          // loop sa requirements
          ...widget.requirements.map((text) => CheckboxListTile(
                value: _checkedItems[text] ?? false,
                onChanged: (bool? newValue) {
                  setState(() {
                    _checkedItems[text] = newValue ?? false;
                  });
                },
                checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                ),
                
                title: Text(text, style: GoogleFonts.inter(fontSize: 15)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                activeColor: widget.iconColor, 
              )),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int num;
  final ServiceStep step;
  final bool isLast;
  final Color accentColor;

  const _StepItem({required this.num, required this.step, required this.isLast, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 25, 
                backgroundColor: accentColor, 
                child: Text("$num", style: const TextStyle(color: Colors.white))),
              // line connecting the step circles
              if (!isLast) 
              Expanded(
                child: VerticalDivider(
                  color: Colors.grey.shade300, 
                  thickness: 2,
                  width: 10, 
                ),
              ),
          ],
        ),
          const SizedBox(width: 30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Office: ${step.office}", 
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(step.instruction, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  
                  const SizedBox(height: 5), // Space bago ang mga buttons

                  // BUTTONS
                  if (num == 1) 
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: [
                          
                          // start nav button
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2057CE),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                
                              ),
                              child: const Text("Start Navigate", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          
                          const SizedBox(width: 10),

                          // mark as done button
                          SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                elevation: 4,
                                side: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("Mark As Done", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
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

class _InfoGrid extends StatelessWidget {
  final ServiceDetail detail;
  final Color accentColor;

  const _InfoGrid({required this.detail, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 25,   
        crossAxisSpacing: 20,   
        childAspectRatio: 1.30, 
      ),
      children: [
        _buildCard(Icons.location_on, "LOCATION", detail.location),
        _buildCard(Icons.access_time_filled, "TIME / DURATION", detail.duration),
        _buildCard(Icons.person, "PERSONNEL", detail.personnel),
        _buildCard(Icons.payments, "TOTAL COST", detail.cost),
      ],
    );
  }

Widget _buildCard(IconData icon, String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), 
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
        // 1. TOP: Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.12), // Very light blue circular background
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF3B73E0), size: 28), // Larger icon size
        ),
        
        // 2. BOTTOM: Text Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sub-label
            Text(
              label, 
              style: GoogleFonts.inter(
                fontSize: 13, 
                color: Colors.black45, 
                fontWeight: FontWeight.w600, 
              ),
            ),
            const SizedBox(height: 10), // Spacing between label and value
            
            // Value
            Text(
              value, 
              style: GoogleFonts.inter(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.black, 
                height: 1.3, 
              ),
            ),
          ],
        ),
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
              Text(
                "OFFICE SCHEDULE",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54, 
                  letterSpacing: 0.5,
                ),
              ),
              
              // open now
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
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15), 

          // date and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monday - Friday",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Text(
                "8:00 AM - 5:00 PM",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}