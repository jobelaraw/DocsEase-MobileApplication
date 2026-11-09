import 'package:docsease/app_modals.dart';
import 'package:docsease/app_tutorial.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  late Stream<List<Office>> _officesStream;
  bool _tutorialStarted = false;

  final FirebaseServices _getService = FirebaseServices();

  @override
  void initState() {
    super.initState();
    // Real-time stream: any add/edit/delete the admin makes on the web
    // portal is pushed here automatically, no manual refresh needed.
    _officesStream = _getService.streamOffices();
    // Keep the ChatBot's cached offices in sync with the live stream too.
    _officesStream.listen((offices) {
      ChatBotScreen.setCachedOffices(offices);

      // First-time tutorial: starts once the services have loaded.
      if (!_tutorialStarted && offices.isNotEmpty && mounted) {
        _tutorialStarted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) AppTutorial.run(context, TutorialSection.home);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Data is already live via the stream above, so there's nothing to
    // re-fetch here. This just gives the pull-to-refresh gesture a brief,
    // familiar completion animation for reassurance.
    return Future.delayed(const Duration(milliseconds: 400));
  }

  Widget buildFilteredCategory(Office office, {bool isFirst = false}) {
    // Safety net: never render an office that has no services.
    if (office.services.isEmpty) return const SizedBox.shrink();

    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    final filteredServices = office.services.where((service) {
      return service.getTitle(lang).toLowerCase().contains(searchQuery);
    }).toList();

    final matchesOfficeTitle = office
        .getOfficeName(lang)
        .toLowerCase()
        .contains(searchQuery);

    if (searchQuery.isNotEmpty &&
        filteredServices.isEmpty &&
        !matchesOfficeTitle) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        TutorialTarget(id: 'home.services', enabled: isFirst, child: ServiceCategory(
          title: office.getOfficeName(lang),
          services: filteredServices.isNotEmpty
              ? filteredServices
              : office.services,
          onTitleChange: widget.onTitleChange,
        )),
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
            Column(
              children: [
                _ServicesSearchBar(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => searchQuery = value.trim().toLowerCase()),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    displacement: 20,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        // StreamBuilder handles the list below the search bar - rebuilds
                        // automatically whenever Firestore pushes an update
                        StreamBuilder<List<Office>>(
                          stream: _officesStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  15,
                                  20,
                                  20,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) =>
                                        const _SkeletonServiceCategory(),
                                    childCount: 4,
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return SliverToBoxAdapter(
                                child: Center(
                                  child: Text(
                                    "Error loading data: ${snapshot.error}",
                                  ),
                                ),
                              );
                            }

                            // Only show offices that actually have at least one
                            // available service. Offices with no services are hidden.
                            final offices = (snapshot.data ?? <Office>[])
                                .where((office) => office.services.isNotEmpty)
                                .toList();

                            if (offices.isEmpty) {
                              return const SliverToBoxAdapter(
                                child: Center(
                                  child: Text("No services available."),
                                ),
                              );
                            }
                            final lang = Provider.of<SettingsProvider>(
                              context,
                              listen: false,
                            ).language;

                            final query = searchQuery.trim().toLowerCase();

                            if (query.isNotEmpty) {
                              final hasResults = offices.any((office) {
                                final matchesOffice = office
                                    .getOfficeName(lang)
                                    .toLowerCase()
                                    .contains(query);

                                final matchesService = office.services.any(
                                  (service) => service
                                      .getTitle(lang)
                                      .toLowerCase()
                                      .contains(query),
                                );

                                return matchesOffice || matchesService;
                              });

                              if (!hasResults) {
                                return SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.search_off_rounded,
                                            size: 55,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.45),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No matching services found',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try a different keyword or check your spelling.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }

                            return SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                15,
                                20,
                                20,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      buildFilteredCategory(offices[index], isFirst: index == 0),
                                  childCount: offices.length,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ), // closes Expanded
              ], // closes Column children
            ), // closes Column
            // Floating Chatbot Button
            Positioned(
              bottom: 20,
              right: 20,
              child: TutorialTarget(id: 'home.chatbot', child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (user == null) {
                      RequireSignInModal.show(
                        context,
                        title: 'Chatbot',
                        onPrimary: () async {
                          final rootNav = Navigator.of(
                            context,
                            rootNavigator: true,
                          );

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
                    widget.onTitleChange('Chatbot');
                    Navigator.push(
                      context,
                      SlideRoute(
                        page: ChatBotScreen(
                          onTitleChange: widget.onTitleChange,
                        ),
                      ),
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
              )),
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

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
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

class _ServicesSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ServicesSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_ServicesSearchBar> createState() => _ServicesSearchBarState();
}

class _ServicesSearchBarState extends State<_ServicesSearchBar> {
  // The focus lives here, so only this small widget rebuilds when focus changes.
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lang = Provider.of<SettingsProvider>(context).language;
    final textColor = scheme.onSurface;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focusNode.hasFocus
                ? scheme.secondary
                : textColor.withValues(alpha: 0.15),
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: (value) {
            setState(() {}); // refreshes the clear (X) button
            widget.onChanged(value);
          },
          style: GoogleFonts.inter(fontSize: 15, color: textColor),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: AppLocalizations.translate('Search service...', lang),
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: textColor.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(Icons.search, size: 25, color: textColor),
            suffixIcon: widget.controller.text.isEmpty
                ? null
                : IconButton(
              icon: Icon(Icons.close, size: 20, color: textColor),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged('');
                setState(() {});
              },
            ),
          ),
        ),
      ),
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
                  ServiceItem(
                    detail: displayedItems[index],
                    onTitleChange: onTitleChange,
                  ),
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
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();

          onTitleChange('Information');
          Navigator.push(
            context,
            SlideRoute(page: InformationScreen(detail: detail)),
          ).then((_) {
            onTitleChange(returnTitle);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
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