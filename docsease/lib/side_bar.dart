import 'package:docsease/about_us.dart';
import 'package:docsease/app_start.dart';
import 'package:docsease/firebase_services.dart';
import 'package:docsease/profile.dart';
import 'package:docsease/services.dart';
import 'package:docsease/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:docsease/navigator_transition.dart';
import 'dart:async';

class SideBar extends StatefulWidget {
  final bool isGuest;
  const SideBar({super.key, this.isGuest = false});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int selectedIndex = 0;
  int _previousIndex = 0;
  String currentTitle = 'Services';
  final GlobalKey<NavigatorState> _servicesNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavKey = GlobalKey<NavigatorState>();
  late final List<Widget> screens;

  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  String currentUsername = 'Loading...';
  String currentProfile = 'assets/default_profile.png';

  @override
  void initState() {
    super.initState();

    _checkInitialConnection();
    _fetchUserData();

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
          setState(() {
            currentTitle = newTitle;
          });
        },
      ),
      ProfileNavigator(
        navigatorKey: _profileNavKey,
        onTitleChange: (newTitle) {
          setState(() {
            currentTitle = newTitle;
          });
        },
      ),
      const AboutUsScreen(),
      const SettingsScreen(),
    ];
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
        // Fetch the rest of the custom profile from Firestore
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

  // List of titles along with the screens
  late final List<String> titles = ['Services', 'Profile', 'About', 'Settings'];

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasDefaultProfile = currentProfile == 'assets/default_profile.png';

    return WillPopScope(
      onWillPop: () async {
        // If we are on the Services tab...
        if (selectedIndex == 0) {
          // Ask the nested Services navigator if it has pages to pop
          bool handledByNested = await _servicesNavKey.currentState?.maybePop() ?? false;
          if (handledByNested) {
            return false; // Handled by nested navigator! Do NOT pop the root.
          }
          return true; // We are at the main Home screen. Let Android close/background the app.
        }

        // If we are on the Profile tab...
        if (selectedIndex == 1) {
          // Ask the nested Profile navigator if it has pages to pop
          bool handledByNested = await _profileNavKey.currentState?.maybePop() ?? false;
          if (handledByNested) {
            return false; // Handled by nested navigator!
          }
          // If at the root of Profile, standard app behavior is to jump back to Home tab
          setState(() {
            selectedIndex = 0;
            currentTitle = 'Services';
          });
          return false;
        }

        // 3. For any other tab (About, Settings), jump back to the Home tab
        setState(() {
          selectedIndex = 0;
          currentTitle = 'Services';
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 60,
          leading:
              ((selectedIndex == 0 && currentTitle != 'Services') ||
                  (selectedIndex == 1 && currentTitle != 'Profile'))
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 6, 15),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (selectedIndex == 0) {
                        _servicesNavKey.currentState?.pop();
                      } else if (selectedIndex == 1) {
                        _profileNavKey.currentState?.pop();
                      }
                    },
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
                    SizedBox(width: 9),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.0),
                          child: ClipOval(
                            child: Image.asset('assets/chatbot_icon.png', fit: BoxFit.contain),
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
                                      color: const Color.fromRGBO(32, 87, 206, 1.0),
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
                                          color: const Color.fromRGBO(32, 87, 206, 1.0),
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
                                          color: const Color.fromRGBO(32, 87, 206, 1.0),
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
                        SizedBox(height: 2),
                        Text(
                          isOnline ? "Online Assistant" : "Offline - Waiting for network...",
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
                  (selectedIndex == 0 || selectedIndex == 1) ? currentTitle : titles[selectedIndex],
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
                      AssetImage('assets/hamburger_icon.png'),
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
          backgroundColor: Color.fromRGBO(32, 87, 206, 1.0),
          surfaceTintColor: Colors.transparent,
          elevation: 1.0,
          shadowColor: Colors.black.withOpacity(0.3),
          toolbarHeight: 70,
        ),
        endDrawer: Drawer(
          width: MediaQuery.of(context).size.width > 400
              ? 300
              : MediaQuery.of(context).size.width * 0.75,
          backgroundColor: const Color.fromARGB(255, 208, 236, 252),
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
                                ? EdgeInsets.all(20)
                                : EdgeInsets.fromLTRB(
                                    20,
                                    MediaQuery.of(context).padding.top + 20,
                                    20,
                                    20,
                                  ),
                            decoration: BoxDecoration(color: Color.fromRGBO(32, 87, 206, 1.0)),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseAuth.instance.currentUser != null
                                  ? FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser!.uid)
                                        .snapshots()
                                  : null,
                              builder: (context, snapshot) {
                                String currentUsername = '...';
                                String currentProfile = 'assets/default_profile.png';

                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data = snapshot.data!.data() as Map<String, dynamic>;
                                  currentUsername = data['username'] ?? 'Guest Account';
                                  currentProfile =
                                      data['profile_img'] ?? 'assets/default_profile.png';
                                }

                                bool hasDefaultProfile =
                                    currentProfile == 'assets/default_profile.png';

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
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
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      currentUsername,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Citizen User',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
                            child: Column(
                              children: [
                                SideBarOption(
                                  selectedImage: 'assets/home_icon.png',
                                  unselectedImage: 'assets/home_outlined_icon.png',
                                  optionName: 'Home',
                                  isSelected: selectedIndex == 0,
                                  onTapAction: () {
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) {
                                        if (selectedIndex == 0) {
                                          _servicesNavKey.currentState?.popUntil(
                                            (route) => route.isFirst,
                                          );

                                          setState(() {
                                            currentTitle = 'Services';
                                          });
                                        } else {
                                          setState(() {
                                            _previousIndex = selectedIndex;
                                            currentTitle = 'Services';
                                            selectedIndex = 0;
                                          });
                                        }
                                      }
                                    });
                                  },
                                ),
                                SizedBox(height: 13),
                                SideBarOption(
                                  selectedImage: 'assets/profile_icon.png',
                                  unselectedImage: 'assets/profile_outlined_icon.png',
                                  optionName: 'Profile',
                                  isSelected: selectedIndex == 1,
                                  onTapAction: () {
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) {
                                        if (selectedIndex == 1) {
                                          _profileNavKey.currentState?.popUntil(
                                            (route) => route.isFirst,
                                          );
                                          setState(() {
                                            currentTitle = 'Profile';
                                          });
                                        } else {
                                          setState(() {
                                            _previousIndex = selectedIndex;
                                            currentTitle = 'Profile';
                                            selectedIndex = 1;
                                          });
                                        }
                                      }
                                    });
                                  },
                                ),
                                SizedBox(height: 13),
                                SideBarOption(
                                  selectedImage: 'assets/about_icon.png',
                                  unselectedImage: 'assets/about_outlined_icon.png',
                                  optionName: 'About',
                                  isSelected: selectedIndex == 2,
                                  onTapAction: () {
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) {
                                        setState(() {
                                          _previousIndex = selectedIndex;
                                          selectedIndex = 2;
                                        });
                                      }
                                    });
                                  },
                                ),
                                SizedBox(height: 13),
                                SideBarOption(
                                  selectedImage: 'assets/settings_icon.png',
                                  unselectedImage: 'assets/settings_outlined_icon.png',
                                  optionName: 'Settings',
                                  isSelected: selectedIndex == 3,
                                  onTapAction: () {
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) {
                                        setState(() {
                                          _previousIndex = selectedIndex;
                                          selectedIndex = 3;
                                        });
                                      }
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
                        padding: const EdgeInsets.only(left: 10, bottom: 20),
                        child: TextButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            if (widget.isGuest) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                SlideRoute(page: const AppStart()),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              await FirebaseServices().signOutUser();
                            }
                          },
                          icon: ImageIcon(
                            AssetImage(widget.isGuest ? "assets/logout_icon.png" : "assets/logout_icon.png"),
                            size: 20,
                            color: const Color.fromRGBO(252, 64, 64, 1),
                          ),
                          label: Text(
                            widget.isGuest ? "Exit" : "Logout",
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
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.white70,
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
        body: TabSwitcher(
          currentIndex: selectedIndex,
          previousIndex: _previousIndex,
          child: screens[selectedIndex],
        ),
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
    final Color currentColor = isSelected ? Color.fromRGBO(59, 115, 224, 1.0) : Colors.black;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTapAction,
        child: Container(
          height: 45,
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                isSelected ? selectedImage : unselectedImage,
                width: 25,
                height: 25,
                // colorFilter: ColorFilter.mode(currentColor, BlendMode.srcIn),
                color: currentColor,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 15),
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
