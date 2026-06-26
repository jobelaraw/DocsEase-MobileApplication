import 'package:docsease/about_us.dart';
import 'package:docsease/app_modals.dart';
import 'package:docsease/authentication.dart';
import 'package:docsease/firebase_services.dart';
import 'package:docsease/main.dart';
import 'package:docsease/profile.dart';
import 'package:docsease/services.dart';
import 'package:docsease/settings.dart';
import 'package:docsease/settings_provider.dart';
import 'package:docsease/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  final bool isGuest;
  const SideBar({super.key, this.isGuest = false});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int selectedIndex = 0;
  // ignore: unused_field
  int _previousIndex = 0;
  String currentTitle = 'Services';

  // Tab History Stack and Titles
  final List<int> _tabHistory = [0];
  List<String> _tabTitles = ['Services', 'Profile', 'About', 'Settings'];

  final GlobalKey<NavigatorState> _servicesNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavKey = GlobalKey<NavigatorState>();
  late final List<Widget> screens;

  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  String currentUsername = 'Loading...';
  String currentProfile = 'assets/default_profile.png';

  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();

    _checkInitialConnection();
    _fetchUserData();

    Provider.of<SettingsProvider>(context, listen: false).loadSettings();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (mounted) {
        setState(() {
          // If the result contains 'none', the user has no internet!
          isOnline = !results.contains(ConnectivityResult.none);
        });
      }
    });

    screens = [
      ServicesNavigator(
        navigatorKey: _servicesNavKey,
        onTitleChange: (newTitle) {
          if (mounted) {
            // Handle tab switch signal from chatbot navigation chips
            // When user taps "Go to Profile/Settings/About" chip in chatbot,
            // it pops back and sends '__switch_tab_X' to switch sidebar tab
            if (newTitle.startsWith('__switch_tab_')) {
              final tabIndex = int.tryParse(newTitle.replaceFirst('__switch_tab_', '')) ?? 0;
              setState(() {
                _tabTitles[0] = 'Services';
              });
              _executeDrawerSwitch(tabIndex);
            } else {
              setState(() {
                _tabTitles[0] = newTitle;
                if (selectedIndex == 0) currentTitle = newTitle;
              });
            }
          }
        },
      ),
      ProfileNavigator(
        navigatorKey: _profileNavKey,
        onTitleChange: (newTitle) {
          if (mounted) {
            setState(() {
              _tabTitles[1] = newTitle;
              if (selectedIndex == 1) currentTitle = newTitle;
            });
          }
        },
      ),
      const AboutUsScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_settingsLoaded) {
      _settingsLoaded = true;
      Provider.of<SettingsProvider>(context, listen: false).loadSettings();
    }
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        isOnline = !results.contains(ConnectivityResult.none);
      });
    }
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              currentUsername = data['username'] ?? 'Guest Account';
              currentProfile = data['profile_img'] ?? 'assets/default_profile.png';
            });
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // --- NEW: Universal wrapper for Drawer Navigation ---
  void _handleDrawerNavigation(int targetIndex) {
    if (selectedIndex == 3 && targetIndex != 3) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      if (settingsProvider.hasUnsavedPreview) {
        ExitConfirmationModal.show(
          context,
          onPrimary: () {
            Navigator.of(context).pop(); // Close modal
            settingsProvider.revertDarkModePreview();
            _executeDrawerSwitch(targetIndex);
          },
          onSecondary: () {
            Navigator.of(context).pop(); // Close modal, abort switch
          },
        );
        return; // Pause execution here until user picks an option
      }
      settingsProvider.revertDarkModePreview(); // Clean up if no changes
    }

    _executeDrawerSwitch(targetIndex);
  }

  // Uses YOUR original logic so deep navigation state is perfectly preserved
  void _executeDrawerSwitch(int targetIndex) {
    if (selectedIndex == targetIndex) {
      if (targetIndex == 0) {
        _servicesNavKey.currentState?.popUntil((route) => route.isFirst);
        setState(() {
          _tabTitles[0] = 'Services';
          currentTitle = 'Services';
        });
      } else if (targetIndex == 1) {
        _profileNavKey.currentState?.popUntil((route) => route.isFirst);
        setState(() {
          _tabTitles[1] = 'Profile';
          currentTitle = 'Profile';
        });
      }
    } else {
      setState(() {
        _previousIndex = selectedIndex;
        _tabHistory.remove(targetIndex);
        _tabHistory.add(targetIndex);
        selectedIndex = targetIndex;
        currentTitle = _tabTitles[targetIndex];
      });
    }
  }

  // Smart back navigation that handles nested screens and the tab history stack
  Future<bool> _handleBackNavigation() async {
    bool handledByNested = false;

    // 1. Give priority to nested navigators (e.g., InformationScreen, EditProfile)
    if (selectedIndex == 0) {
      handledByNested = await _servicesNavKey.currentState?.maybePop() ?? false;
    } else if (selectedIndex == 1) {
      handledByNested = await _profileNavKey.currentState?.maybePop() ?? false;
    }

    // 2. If a nested page was popped, we're done here.
    if (handledByNested) {
      return false; // Tells WillPopScope not to exit the app
    }

    // 3. If we are at the root of a tab, pop the History Stack instead!
    if (_tabHistory.length > 1) {
      if (selectedIndex == 3) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

        if (settingsProvider.hasUnsavedPreview) {
          ExitConfirmationModal.show(
            context,
            onPrimary: () {
              Navigator.of(context).pop();
              settingsProvider.revertDarkModePreview();
              setState(() {
                _previousIndex = selectedIndex;
                _tabHistory.removeLast(); // Remove current tab
                selectedIndex = _tabHistory.last; // Navigate to the previous tab

                // Restore exactly the title we left off on for this specific tab
                currentTitle = _tabTitles[selectedIndex];
              });
            },
            onSecondary: () {
              Navigator.of(context).pop();
            },
          );
          return false; // don't switch tab yet, wait for user's choice
        }

        // No unsaved changes, just switch normally
        settingsProvider.revertDarkModePreview();
      }
      setState(() {
        _previousIndex = selectedIndex;
        _tabHistory.removeLast(); // Remove current tab
        selectedIndex = _tabHistory.last; // Navigate to the previous tab

        // Restore exactly the title we left off on for this specific tab
        currentTitle = _tabTitles[selectedIndex];
      });
      return false;
    }

    // 4. If history only has 1 item left (Home), exit the app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 60,
          // Hide back button ONLY on absolute root 'Services' view
          leading: !(selectedIndex == 0 && currentTitle == 'Services')
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 6, 15),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: _handleBackNavigation, // Uses the smart back logic
                  ),
                )
              : null,
          centerTitle: (selectedIndex == 0 && currentTitle == 'Chatbot') ? false : true,
          titleSpacing: 0,
          title: selectedIndex == 0 && currentTitle == 'Chatbot'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 9),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: ClipOval(
                            child: Image.asset(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 'assets/chatbot_darkmode.png'
                                  : 'assets/chatbot_icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: isOnline
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39D236),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "DocsEase Bot",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOnline
                              ? AppLocalizations.translate(
                                  'Online Assistant',
                                  Provider.of<SettingsProvider>(context).language,
                                )
                              : AppLocalizations.translate(
                                  'Offline - Waiting for network...',
                                  Provider.of<SettingsProvider>(context).language,
                                ),
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  AppLocalizations.translate(
                    currentTitle,
                    Provider.of<SettingsProvider>(context).language,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          actions: [
            Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: IconButton(
                    splashRadius: 10.0,
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: ImageIcon(
                      const AssetImage('assets/hamburger_icon.png'),
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                );
              },
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.primary,
          surfaceTintColor: Colors.transparent,
          elevation: 1.0,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          toolbarHeight: 70,
        ),
        endDrawer: Drawer(
          width: MediaQuery.of(context).size.width > 400
              ? 300
              : MediaQuery.of(context).size.width * 0.75,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(0.0),
              bottomRight: Radius.circular(0.0),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Container(
                            padding: MediaQuery.of(context).padding.top < 20
                                ? const EdgeInsets.all(20)
                                : EdgeInsets.fromLTRB(
                                    20,
                                    MediaQuery.of(context).padding.top + 20,
                                    20,
                                    20,
                                  ),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseAuth.instance.currentUser != null
                                  ? FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser!.uid)
                                        .snapshots()
                                  : null,
                              builder: (context, snapshot) {
                                // Quick bypass for Guests
                                if (widget.isGuest) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        child: ClipOval(
                                          child: Image.asset(
                                            'assets/default_profile.png',
                                            width: 75,
                                            height: 75,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Guest Account',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.translate(
                                          'Citizen User',
                                          Provider.of<SettingsProvider>(context).language,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                // Force the skeleton if a Real User's data is missing, syncing, or waiting!
                                if (snapshot.connectionState == ConnectionState.waiting ||
                                    !snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const _SkeletonProfileHeader();
                                }

                                // Assign the data
                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                String currentUsername = data['username'] ?? 'Unknown User';
                                String currentProfile =
                                    data['profile_img'] ?? 'assets/default_profile.png';
                                bool hasDefaultProfile =
                                    currentProfile == 'assets/default_profile.png';

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      child: ClipOval(
                                        child: hasDefaultProfile
                                            ? Image.asset(
                                                currentProfile,
                                                width: 75,
                                                height: 75,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                currentProfile,
                                                width: 75,
                                                height: 75,
                                                fit: BoxFit.cover,
                                                // NEW: Make the image shimmer while downloading!
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return _ShimmerEffect(
                                                    child: Container(
                                                      width: 75,
                                                      height: 75,
                                                      color: Colors.white.withValues(alpha: 0.5),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (_, __, ___) => Image.asset(
                                                  'assets/default_profile.png',
                                                  width: 75,
                                                  height: 75,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      currentUsername,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.translate(
                                        'Citizen User',
                                        Provider.of<SettingsProvider>(context).language,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
                            child: Column(
                              children: [
                                SideBarOption(
                                  selectedImage: 'assets/home_icon.png',
                                  unselectedImage: 'assets/home_outlined_icon.png',
                                  optionName: AppLocalizations.translate(
                                    'Home',
                                    Provider.of<SettingsProvider>(context).language,
                                  ),
                                  isSelected: selectedIndex == 0,
                                  onTapAction: () {
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) _handleDrawerNavigation(0);
                                    });
                                  },
                                ),
                                const SizedBox(height: 13),
                                SideBarOption(
                                  selectedImage: 'assets/profile_icon.png',
                                  unselectedImage: 'assets/profile_outlined_icon.png',
                                  optionName: AppLocalizations.translate(
                                    'Profile',
                                    Provider.of<SettingsProvider>(context).language,
                                  ),
                                  isSelected: selectedIndex == 1,
                                  onTapAction: () async {
                                    if (widget.isGuest) {
                                      Navigator.pop(context);
                                      await Future.delayed(const Duration(milliseconds: 200));
                                      RequireSignInModal.show(
                                        context,
                                        title: 'Profile',
                                        onPrimary: () async {
                                          Hive.box('auth_box').put('continueGuest', false);

                                          Navigator.pop(context);

                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) => const AuthWrapper(),
                                            ),
                                            (route) => false,
                                          );
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => const Authentication(),
                                            ),
                                          );
                                        },
                                      );
                                      return;
                                    }
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) _handleDrawerNavigation(1);
                                    });
                                  },
                                ),
                                const SizedBox(height: 13),
                                SideBarOption(
                                  selectedImage: 'assets/about_icon.png',
                                  unselectedImage: 'assets/about_outlined_icon.png',
                                  optionName: AppLocalizations.translate(
                                    'About',
                                    Provider.of<SettingsProvider>(context).language,
                                  ),
                                  isSelected: selectedIndex == 2,
                                  onTapAction: () {
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) _handleDrawerNavigation(2);
                                    });
                                  },
                                ),
                                const SizedBox(height: 13),
                                SideBarOption(
                                  selectedImage: 'assets/settings_icon.png',
                                  unselectedImage: 'assets/settings_outlined_icon.png',
                                  optionName: AppLocalizations.translate(
                                    'Settings',
                                    Provider.of<SettingsProvider>(context).language,
                                  ),
                                  isSelected: selectedIndex == 3,
                                  onTapAction: () {
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) _handleDrawerNavigation(3);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 20),
                        child: TextButton.icon(
                          onPressed: () async {
                            final settingsProvider = Provider.of<SettingsProvider>(
                              context,
                              listen: false,
                            );
                            final nav = Navigator.of(context, rootNavigator: true);

                            Navigator.pop(context);
                            await Future.delayed(const Duration(milliseconds: 200));
                            if (!mounted) return;

                            LogoutModal.show(
                              context,
                              hasUnsavedChanges: settingsProvider.hasUnsavedPreview,
                              isGuest: widget.isGuest,
                              onPrimary: () async {
                                settingsProvider.revertDarkModePreview();
                                nav.pop(); // Close the logout modal

                                if (widget.isGuest) {
                                  Hive.box('auth_box').put('continueGuest', false);
                                } else {
                                  await FirebaseServices().signOutUser();
                                if (context.mounted) {
                                  await Provider.of<SettingsProvider>(context, listen: false).loadSettings();
                                }
                                  
                                if (context.mounted) {
                                  await settingsProvider.saveSettings(false, settingsProvider.language, 0.5);
                                }

                                nav.pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                                  (route) => false,
                                );
                                nav.push(
                                  MaterialPageRoute(builder: (context) => const Authentication()),
                                );
                              },
                            );
                          },
                          icon: ImageIcon(
                            AssetImage(
                              widget.isGuest ? "assets/logout_icon.png" : "assets/logout_icon.png",
                            ),
                            size: 20,
                            color: const Color.fromRGBO(252, 64, 64, 1),
                          ),
                          label: Text(
                            AppLocalizations.translate(
                              widget.isGuest ? 'Exit' : 'Logout',
                              Provider.of<SettingsProvider>(context).language,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(252, 64, 64, 1),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color.fromRGBO(252, 64, 64, 1),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w100,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        // USING INDEXED STACK TO PRESERVE WIDGET STATES!
        body: IndexedStack(index: selectedIndex, children: screens),
      ),
    );
  }
}

class SideBarOption extends StatelessWidget {
  final String selectedImage;
  final String unselectedImage;
  final String optionName;
  final bool isSelected;
  final VoidCallback onTapAction;

  const SideBarOption({
    super.key,
    required this.selectedImage,
    required this.unselectedImage,
    required this.optionName,
    required this.isSelected,
    required this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    final Color currentColor = isSelected
        ? const Color.fromRGBO(59, 115, 224, 1.0)
        : Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTapAction,
        child: Container(
          height: 50,
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                isSelected ? selectedImage : unselectedImage,
                width: 25,
                height: 25,
                color: currentColor,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 15),
              Text(
                optionName,
                style: isSelected
                    ? GoogleFonts.archivoBlack(fontSize: 15, color: currentColor)
                    : GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: currentColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServicesNavigator extends StatelessWidget {
  final Function(String) onTitleChange;
  final GlobalKey<NavigatorState> navigatorKey;

  const ServicesNavigator({super.key, required this.onTitleChange, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => Services(onTitleChange: onTitleChange));
      },
    );
  }
}

class ProfileNavigator extends StatelessWidget {
  final Function(String) onTitleChange;
  final GlobalKey<NavigatorState> navigatorKey;

  const ProfileNavigator({super.key, required this.onTitleChange, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => Profile(onTitleChange: onTitleChange));
      },
    );
  }
}

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

class _SkeletonProfileHeader extends StatelessWidget {
  const _SkeletonProfileHeader();

  @override
  Widget build(BuildContext context) {
    // Read the app's dynamic text scale factor from your SettingsProvider
    final textScaler = MediaQuery.textScalerOf(context);

    return _ShimmerEffect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 17),
          Container(
            width: 120,
            height: textScaler.scale(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(height: textScaler.scale(5)),
          Container(
            width: 80,
            height: textScaler.scale(10.5),
            margin: EdgeInsets.only(top: textScaler.scale(3)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
