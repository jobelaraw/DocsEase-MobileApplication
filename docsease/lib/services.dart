import 'package:flutter/material.dart';
import 'package:docsease/chatbot.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_list.dart';
import 'information.dart';

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

List<ServiceItem> buildServiceItems(
  List<ServiceData> dataList,
  Function(String) onTitleChange,
) {
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
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero, () {
      _searchFocusNode.unfocus();
    });
  }

  Widget buildFilteredCategory({
    required String title,
    required List<ServiceData> dataList,
  }) {
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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Search Bar
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        158,
                        158,
                        158,
                      ).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      GestureDetector(
                        onTap: () {
                          // TODO: Search action
                        },
                        child: Icon(
                          Icons.search,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          autofocus: false,

                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },

                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search transaction.......',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 18,
                              color: const Color.fromARGB(255, 143, 140, 140),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                buildFilteredCategory(
                  title: 'Business Permit and Licensing',
                  dataList: ServiceLists.officeBusinessLicensing,
                ),

                buildFilteredCategory(
                  title: 'Office of the Building Official',
                  dataList: ServiceLists.officeBuildingOfficial,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Engineer',
                  dataList: ServiceLists.officeCityEngineer,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Assessor',
                  dataList: ServiceLists.officeCityAssessor,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Civil Registrar',
                  dataList: ServiceLists.officeCivilRegistry,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Treasurer',
                  dataList: ServiceLists.officeCityTreasurer,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Mayor',
                  dataList: ServiceLists.officeCityMayor,
                ),

                buildFilteredCategory(
                  title:
                      'Office of the City Vice Mayor/ SP & Secretary to the Sanggunian',
                  dataList: ServiceLists.officeCityVmSpSecretarySangunian,
                ),

                buildFilteredCategory(
                  title: 'Information and Communications Technology Office',
                  dataList: ServiceLists.officeICT,
                ),

                buildFilteredCategory(
                  title: 'City Human Resources and Development Office',
                  dataList: ServiceLists.officeCityHRDevelopment,
                ),

                buildFilteredCategory(
                  title: 'Public Employment Services Office',
                  dataList: ServiceLists.officePublicEmploymentServices,
                ),

                buildFilteredCategory(
                  title:
                      'Office of the City Environmental and Natural Resources Officer',
                  dataList: ServiceLists.officeCENR,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Population Officer',
                  dataList: ServiceLists.officeCityPopulationOfficer,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Cooperatives Officer',
                  dataList: ServiceLists.officeCityCooperativesOfficer,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Information Officer',
                  dataList: ServiceLists.officeCityInformationOfficer,
                ),

                buildFilteredCategory(
                  title:
                      'Office of the City Social Welfare and Development Officer',
                  dataList: ServiceLists.officeCSWD,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Accountant',
                  dataList: ServiceLists.officeCityAccount,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Legal Officer',
                  dataList: ServiceLists.officeCityLegalOfficer,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Agriculturist',
                  dataList: ServiceLists.officeCityAgriculturist,
                ),

                buildFilteredCategory(
                  title:
                      'Office of the City Planning and Development Coordinator',
                  dataList: ServiceLists.officeCityPlanningDevCoor,
                ),

                buildFilteredCategory(
                  title: 'City Human Settlements and Livelihood Office',
                  dataList: ServiceLists.officecCityHumanSettlementsLivelihood,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Budget Officer',
                  dataList: ServiceLists.officeCityBudgetOfficer,
                ),

                buildFilteredCategory(
                  title: 'Office of the City General Services Officer',
                  dataList: ServiceLists.officeCityGeneralServicesOfficer,
                ),

                buildFilteredCategory(
                  title: 'Office of the City Health Officer',
                  dataList: ServiceLists.officeCityHealthOfficer,
                ),

                buildFilteredCategory(
                  title: 'City Health Office II',
                  dataList: ServiceLists.officeCityHealthOfficerII,
                ),

                buildFilteredCategory(
                  title: 'City Health Office II- Biñan Birthing Home',
                  dataList: ServiceLists.officeCityHealthOfficerIIBirthingHome,
                ),

                buildFilteredCategory(
                  title: 'City Disaster Risk Reduction and Management Office',
                  dataList: ServiceLists.officeCDRRM,
                ),

                buildFilteredCategory(
                  title: 'Public Order and Safety Office',
                  dataList: ServiceLists.officePublicOrderAndSafety,
                ),
              ],
            ),

            // Floating Chatbot Button
            Positioned(
              bottom: 40,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onTitleChange('Chatbot');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatBotScreen(),
                      ),
                    ).then((_) {
                      widget.onTitleChange('Services');
                    });
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset(
                      'assets/chatbot_icon.png',
                      width: 70,
                      height: 70,
                    ),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                  MaterialPageRoute(
                    builder: (context) => SeeAllScreen(
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
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color.fromRGBO(32, 87, 206, 1.0),
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
            color: const Color.fromRGBO(185, 217, 235, 1.0),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: List.generate(displayedItems.length, (index) {
              return Column(
                children: [
                  displayedItems[index],
                  if (index != displayedItems.length - 1)
                    const SizedBox(height: 12),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          onTitleChange('Information');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InformationScreen(title: label),
            ),
          ).then((_) {
            onTitleChange(returnTitle);
          });
        },

        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 35,
                color: const Color.fromARGB(255, 0, 0, 0),
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(185, 217, 235, 1.0),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: List.generate(dynamicItems.length, (index) {
              return Column(
                children: [
                  dynamicItems[index],
                  if (index != dynamicItems.length - 1)
                    const SizedBox(height: 10),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
