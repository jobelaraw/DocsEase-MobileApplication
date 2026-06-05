import 'package:flutter/material.dart';
import 'package:docsease/chatbot.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_list.dart';
import 'information.dart';
import 'navigator_transition.dart';

class ServiceData {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const ServiceData({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

List<ServiceItem> buildServiceItems(List<ServiceData> dataList, Function(String) onTitleChange) {
  return dataList.map((data) {
    return ServiceItem(
      data: data,
      label: data.label,
      iconData: data.icon,
      iconBgColor: data.bgColor,
      iconColor: data.iconColor,
      onTitleChange: onTitleChange,
    );
  }).toList();
}

class Services extends StatefulWidget {
  final Function(String) onTitleChange;

  const Services({super.key, required this.onTitleChange});

  @override
  State<Services> createState() => _ServicesContent();
}

class _ServicesContent extends State<Services> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  List<ServiceItem> filterItems(List<ServiceItem> items) {
    if (searchQuery.isEmpty) return items;

    return items.where((item) {
      return item.label.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Tells the app to rebuild the UI whenever the focus changes (clicked or unclicked)
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget buildFilteredCategory({required String title, required List<ServiceData> dataList}) {
    final items = buildServiceItems(dataList, widget.onTitleChange);

    final filtered = items.where((item) {
      return item.label.toLowerCase().contains(searchQuery);
    }).toList();

    final matchesTitle = title.toLowerCase().contains(searchQuery);

    if (searchQuery.isNotEmpty && filtered.isEmpty && !matchesTitle) {
      return const SizedBox.shrink(); // hide category
    }

    return Column(
      children: [
        ServiceCategory(
          title: title,
          items: filtered.isNotEmpty ? filtered : items,
          onTitleChange: widget.onTitleChange,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    hasFocus: _searchFocusNode.hasFocus,
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    brightness: Theme.of(context).brightness,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      buildFilteredCategory(title: 'Business Permit and Licensing', dataList: ServiceLists.officeBusinessLicensing),
                      buildFilteredCategory(title: 'Office of the Building Official', dataList: ServiceLists.officeBuildingOfficial),
                      buildFilteredCategory(title: 'Office of the City Engineer', dataList: ServiceLists.officeCityEngineer),
                      buildFilteredCategory(title: 'Office of the City Assessor', dataList: ServiceLists.officeCityAssessor),
                      buildFilteredCategory(title: 'Office of the City Civil Registrar', dataList: ServiceLists.officeCivilRegistry),
                      buildFilteredCategory(title: 'Office of the City Treasurer', dataList: ServiceLists.officeCityTreasurer),
                      buildFilteredCategory(title: 'Office of the City Mayor', dataList: ServiceLists.officeCityMayor),
                      buildFilteredCategory(title: 'Office of the City Vice Mayor/ SP & Secretary to the Sanggunian', dataList: ServiceLists.officeCityVmSpSecretarySangunian),
                      buildFilteredCategory(title: 'Information and Communications Technology Office', dataList: ServiceLists.officeICT),
                      buildFilteredCategory(title: 'City Human Resources and Development Office', dataList: ServiceLists.officeCityHRDevelopment),
                      buildFilteredCategory(title: 'Public Employment Services Office', dataList: ServiceLists.officePublicEmploymentServices),
                      buildFilteredCategory(title: 'Office of the City Environmental and Natural Resources Officer', dataList: ServiceLists.officeCENR),
                      buildFilteredCategory(title: 'Office of the City Population Officer', dataList: ServiceLists.officeCityPopulationOfficer),
                      buildFilteredCategory(title: 'Office of the City Cooperatives Officer', dataList: ServiceLists.officeCityCooperativesOfficer),
                      buildFilteredCategory(title: 'Office of the City Information Officer', dataList: ServiceLists.officeCityInformationOfficer),
                      buildFilteredCategory(title: 'Office of the City Social Welfare and Development Officer', dataList: ServiceLists.officeCSWD),
                      buildFilteredCategory(title: 'Office of the City Accountant', dataList: ServiceLists.officeCityAccount),
                      buildFilteredCategory(title: 'Office of the City Legal Officer', dataList: ServiceLists.officeCityLegalOfficer),
                      buildFilteredCategory(title: 'Office of the City Agriculturist', dataList: ServiceLists.officeCityAgriculturist),
                      buildFilteredCategory(title: 'Office of the City Planning and Development Coordinator', dataList: ServiceLists.officeCityPlanningDevCoor),
                      buildFilteredCategory(title: 'City Human Settlements and Livelihood Office', dataList: ServiceLists.officecCityHumanSettlementsLivelihood),
                      buildFilteredCategory(title: 'Office of the City Budget Officer', dataList: ServiceLists.officeCityBudgetOfficer),
                      buildFilteredCategory(title: 'Office of the City General Services Officer', dataList: ServiceLists.officeCityGeneralServicesOfficer),
                      buildFilteredCategory(title: 'Office of the City Health Officer', dataList: ServiceLists.officeCityHealthOfficer),
                      buildFilteredCategory(title: 'City Health Office II', dataList: ServiceLists.officeCityHealthOfficerII),
                      buildFilteredCategory(title: 'City Health Office II- Biñan Birthing Home', dataList: ServiceLists.officeCityHealthOfficerIIBirthingHome),
                      buildFilteredCategory(title: 'City Disaster Risk Reduction and Management Office', dataList: ServiceLists.officeCDRRM),
                      buildFilteredCategory(title: 'Public Order and Safety Office', dataList: ServiceLists.officePublicOrderAndSafety),
                    ]),
                  ),
                ),
              ],
            ),
            // Floating Chatbot Button
            Positioned(
              bottom: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onTitleChange('Chatbot');
                    Navigator.push(
                      context,
                      SlideRoute(page: const ChatBotScreen()),
                    ).then((_) => widget.onTitleChange('Services'));
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset('assets/chatbot_icon.png', width: 70, height: 70),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool hasFocus;
  final ValueChanged<String> onChanged;
  final Brightness brightness;

  const _SearchBarDelegate({
    required this.focusNode,
    required this.controller,
    required this.hasFocus,
    required this.onChanged,
    required this.brightness,
  });

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  bool shouldRebuild(_SearchBarDelegate old) =>
      old.hasFocus != hasFocus || old.controller != controller || old.brightness != brightness; 

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        onTap: () => focusNode.requestFocus(),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFocus
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(Icons.search, color:Theme.of(context).colorScheme.onSurface, size: 25),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: false,
                  onChanged: onChanged,
                  style: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search service...',
                    hintStyle: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCategory extends StatelessWidget {
  final String title;
  final List<ServiceItem> items;
  final Function(String) onTitleChange;

  const ServiceCategory({
    super.key,
    required this.title,
    required this.items,
    required this.onTitleChange,
  });

  @override
  Widget build(BuildContext context) {
    final displayedItems = items.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.black,
                ),
                softWrap: true,
              ),
            ),

            const SizedBox(width: 10),

            // See all Button
            TextButton(
              onPressed: () {
                onTitleChange(title);
                Navigator.push(
                  context,
                  SlideRoute(
                    page: SeeAllScreen(
                      title: title,
                      items: items,
                      onTitleChange: onTitleChange,
                    ),
                  ),
                ).then((_) {
                  onTitleChange('Services');
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Light blue wrapper container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: List.generate(displayedItems.length, (index) {
              return Column(
                children: [
                  displayedItems[index],
                  if (index != displayedItems.length - 1) const SizedBox(height: 12),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String label;
  final IconData iconData;
  final Color iconBgColor;
  final Color iconColor;
  final ServiceData data;
  final Function(String) onTitleChange;
  final String returnTitle;

  const ServiceItem({
    super.key,
    required this.data,
    required this.label,
    required this.iconData,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTitleChange,
    this.returnTitle = 'Services',
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.tertiary
      : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();

          onTitleChange('Information');
          Navigator.push(
            context,
            SlideRoute(page: InformationScreen(title: label)),
          ).then((_) {
            onTitleChange(returnTitle);
          });
        },

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ImageIcon(
                AssetImage('assets/forward_icon.png'),
                size: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SeeAllScreen extends StatelessWidget {
  //Appbar here
  final String title;
  final List<ServiceItem> items;
  final Function(String) onTitleChange;

  const SeeAllScreen({
    super.key,
    required this.title,
    required this.items,
    required this.onTitleChange,
  });

  @override
  Widget build(BuildContext context) {
    final dynamicItems = items.map((oldItem) {
      return ServiceItem(
        data: oldItem.data,
        label: oldItem.label,
        iconData: oldItem.iconData,
        iconBgColor: oldItem.iconBgColor,
        iconColor: oldItem.iconColor,
        onTitleChange: onTitleChange,
        returnTitle: title,
      );
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: List.generate(dynamicItems.length, (index) {
              return Column(
                children: [
                  dynamicItems[index],
                  if (index != dynamicItems.length - 1) const SizedBox(height: 10),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
