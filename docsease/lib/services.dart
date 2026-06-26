import 'package:docsease/app_modals.dart';
import 'package:docsease/authentication.dart';
import 'package:docsease/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/info_model.dart';
import 'package:docsease/information.dart';
import 'package:docsease/chatbot.dart';
import 'package:docsease/navigator_transition.dart';
import 'package:docsease/firebase_services.dart';
import 'package:docsease/app_localizations.dart';
import 'package:docsease/settings_provider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

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

  late Future<List<Office>> _officesFuture;

  final FirebaseServices _getService = FirebaseServices();

  @override
  void initState() {
    super.initState();
    // Preload offices and share with ChatBot so related services load instantly
    _officesFuture = _getService.getOffices().then((offices) {
      ChatBotScreen.setCachedOffices(offices);
      return offices;
    });
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      // Re-fetch the data. This automatically forces the FutureBuilder
      _officesFuture = _getService.getOffices();
    });

    // Return immediately instead of awaiting the full Firebase fetch.
    return Future.delayed(const Duration(milliseconds: 100));
  }

  Widget buildFilteredCategory(Office office) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    final filteredServices = office.services.where((service) {
      return service.getTitle(lang).toLowerCase().contains(searchQuery);
    }).toList();

    final matchesOfficeTitle = office.getOfficeName(lang).toLowerCase().contains(searchQuery);

    if (searchQuery.isNotEmpty && filteredServices.isEmpty && !matchesOfficeTitle) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ServiceCategory(
          title: office.getOfficeName(lang),
          services: filteredServices.isNotEmpty ? filteredServices : office.services,
          onTitleChange: widget.onTitleChange,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Provider.of<SettingsProvider>(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              displacement: 20,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // --- UPDATED SEARCH BAR DELEGATE ---
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SearchBarDelegate(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      hasFocus: _searchFocusNode.hasFocus,
                      onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    ),
                  ),

                  // FutureBuilder handles the list below the search bar
                  FutureBuilder<List<Office>>(
                    future: _officesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const _SkeletonServiceCategory(),
                              childCount: 4,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Center(child: Text("Error loading data: ${snapshot.error}")),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(child: Text("No services available.")),
                        );
                      }

                      final offices = snapshot.data!;
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => buildFilteredCategory(offices[index]),
                            childCount: offices.length,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Floating Chatbot Button
            Positioned(
              bottom: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (user == null) {
                      RequireSignInModal.show(
                        context,
                        title: 'Chatbot',
                        onPrimary: () async {
                          final rootNav = Navigator.of(context, rootNavigator: true);

                          Hive.box('auth_box').put('continueGuest', false);

                          rootNav.pop();

                          rootNav.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const AuthWrapper()),
                            (route) => false,
                          );
                          rootNav.push(
                            MaterialPageRoute(builder: (context) => const Authentication()),
                          );
                        },
                      );
                      return;
                    }
                    widget.onTitleChange('Chatbot');
                    Navigator.push(
                      context,
                      SlideRoute(page: const ChatBotScreen()),
                    ).then((result) {
                      // Handle chatbot navigation chip result:
                      // If user tapped "Go to Profile/Settings/About", switch sidebar tab
                      // Otherwise just reset title back to 'Services'
                      if (result != null && result is int && result != 0) {
                        widget.onTitleChange('__switch_tab_$result');
                      } else {
                        widget.onTitleChange('Services');
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/chatbot_darkmode.png'
                          : 'assets/chatbot_icon.png',
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

// --- SKELETON WIDGETS FOR SERVICES --- //

class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 0.8).animate(_controller),
      child: widget.child,
    );
  }
}

class _SkeletonServiceCategory extends StatelessWidget {
  const _SkeletonServiceCategory();

  @override
  Widget build(BuildContext context) {
    return _ShimmerEffect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                width: 50,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: List.generate(3, (index) {
                return Column(
                  children: [
                    Container(
                      height: 78,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 100,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 18,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != 2) const SizedBox(height: 12),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool hasFocus;
  final ValueChanged<String> onChanged;

  const _SearchBarDelegate({
    required this.focusNode,
    required this.controller,
    required this.hasFocus,
    required this.onChanged,
  });

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  bool shouldRebuild(_SearchBarDelegate old) =>
      old.hasFocus != hasFocus || old.controller != controller;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
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
                  Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface, size: 25),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: false,
                      onChanged: onChanged,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        // Seamlessly updates translation without scrolling
                        hintText: AppLocalizations.translate(
                          'Search service...',
                          settings.language,
                        ),
                        hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
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
      },
    );
  }
}

class ServiceCategory extends StatelessWidget {
  final String title;
  final List<ServiceDetail> services;
  final Function(String) onTitleChange;

  const ServiceCategory({
    super.key,
    required this.title,
    required this.services,
    required this.onTitleChange,
  });

  @override
  Widget build(BuildContext context) {
    final displayedItems = services.take(3).toList();

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
            TextButton(
              onPressed: () {
                onTitleChange(title);
                Navigator.push(
                  context,
                  SlideRoute(
                    page: SeeAllScreen(
                      title: title,
                      services: services,
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
                AppLocalizations.translate(
                  'See All',
                  Provider.of<SettingsProvider>(context).language,
                ),
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
                  ServiceItem(detail: displayedItems[index], onTitleChange: onTitleChange),
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
  final ServiceDetail detail;
  final Function(String) onTitleChange;
  final String returnTitle;

  const ServiceItem({
    super.key,
    required this.detail,
    required this.onTitleChange,
    this.returnTitle = 'Services',
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).language;
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
          Navigator.push(context, SlideRoute(page: InformationScreen(detail: detail))).then((_) {
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
                  color: UIHelper.getBgColorForService(detail.title),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  UIHelper.getIconForService(detail.title),
                  size: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  detail.getTitle(lang),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ImageIcon(
                const AssetImage('assets/forward_icon.png'),
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
  final String title;
  final List<ServiceDetail> services;
  final Function(String) onTitleChange;

  const SeeAllScreen({
    super.key,
    required this.title,
    required this.services,
    required this.onTitleChange,
  });

  @override
  Widget build(BuildContext context) {
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
            children: List.generate(services.length, (index) {
              return Column(
                children: [
                  ServiceItem(
                    detail: services[index],
                    onTitleChange: onTitleChange,
                    returnTitle: title,
                  ),
                  if (index != services.length - 1) const SizedBox(height: 10),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
