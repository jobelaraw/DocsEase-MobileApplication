import 'package:docsease/about_us.dart';
import 'package:docsease/authentication.dart';
import 'package:docsease/profile.dart';
import 'package:docsease/services.dart';
import 'package:docsease/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int selectedIndex = 0;
  String currentTitle = 'Services';
  final GlobalKey<NavigatorState> _servicesNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavKey = GlobalKey<NavigatorState>();
  late final List<Widget> screens;

  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    _checkInitialConnection();

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

  // List of titles along with the screens
  late final List<String> titles = ['Services', 'Profile', 'About', 'Settings'];

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        centerTitle: (selectedIndex == 0 && currentTitle == 'Chatbot')
            ? false
            : true,
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
                          child: Image.asset(
                            'assets/chatbot_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: isOnline
                            // ? Stack(
                            //     children: [
                            //       Container(
                            //         width: 12,
                            //         height: 12,
                            //         decoration: BoxDecoration(
                            //           color: Colors.grey,
                            //           shape: BoxShape.circle,
                            //           border: Border.all(
                            //             color: const Color.fromRGBO(
                            //               32,
                            //               87,
                            //               206,
                            //               1.0,
                            //             ),
                            //             width: 1.5,
                            //           ),
                            //         ),
                            //       ),
                            //       Positioned(
                            //         top: 4,
                            //         left: 4,
                            //         child: Container(
                            //           width: 4,
                            //           height: 4,
                            //           decoration: BoxDecoration(
                            //             color: const Color.fromRGBO(
                            //               32,
                            //               87,
                            //               206,
                            //               1.0,
                            //             ),
                            //             shape: BoxShape.circle,
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   )
                            // // Container(
                            // //   width: 12,
                            // //   height: 12,
                            // //   decoration: BoxDecoration(
                            // //     color: const Color.fromARGB(255, 210, 54, 54),
                            // //     shape: BoxShape.circle,
                            // //     border: Border.all(
                            // //       color: const Color.fromRGBO(
                            // //         32,
                            // //         87,
                            // //         206,
                            // //         1.0,
                            // //       ),
                            // //       width: 1.5,
                            // //     ),
                            // //   ),
                            // // )
                            // : Container(
                            //     width: 12,
                            //     height: 12,
                            //     decoration: BoxDecoration(
                            //       color: const Color(0xFF39D236),
                            //       shape: BoxShape.circle,
                            //       border: Border.all(
                            //         color: const Color.fromRGBO(
                            //           32,
                            //           87,
                            //           206,
                            //           1.0,
                            //         ),
                            //         width: 1.5,
                            //       ),
                            //     ),
                            //   ),
                            ? Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF39D236),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color.fromRGBO(
                                      32,
                                      87,
                                      206,
                                      1.0,
                                    ),
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
                                        color: const Color.fromRGBO(
                                          32,
                                          87,
                                          206,
                                          1.0,
                                        ),
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
                                        color: const Color.fromRGBO(
                                          32,
                                          87,
                                          206,
                                          1.0,
                                        ),
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
                        isOnline
                            ? "Online Assistant"
                            : "Offline - Waiting for network...",
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
                (selectedIndex == 0 || selectedIndex == 1)
                    ? currentTitle
                    : titles[selectedIndex],
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
                            MediaQuery.of(context).padding.top,
                            20,
                            20,
                          ),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(32, 87, 206, 1.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            child: const ImageIcon(
                              AssetImage('assets/close_icon.png'),
                              size: 20,
                              color: Colors.white,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white30,
                          child: Image.asset(
                            'assets/default_profile.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Guest Account',
                          style: GoogleFonts.inter(
                            fontSize: 13,
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
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
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
                                      currentTitle = 'Services';
                                      selectedIndex = 0;
                                    });
                                  }
                                }
                              },
                            );
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
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
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
                                      currentTitle = 'Profile';
                                      selectedIndex = 1;
                                    });
                                  }
                                }
                              },
                            );
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
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
                                if (mounted) {
                                  setState(() {
                                    selectedIndex = 2;
                                  });
                                }
                              },
                            );
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
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
                                if (mounted) {
                                  setState(() {
                                    selectedIndex = 3;
                                  });
                                }
                              },
                            );
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
                  // For later when basic authentication is done
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Authentication()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: ImageIcon(
                    AssetImage("assets/logout_icon.png"),
                    size: 20,
                    color: Color.fromRGBO(252, 64, 64, 1),
                  ),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(252, 64, 64, 1),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromRGBO(252, 64, 64, 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: screens[selectedIndex],
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
        ? Color.fromRGBO(59, 115, 224, 1.0)
        : Colors.black;

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
                    ? GoogleFonts.archivoBlack(
                        fontSize: 15,
                        color: currentColor,
                      )
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

  const ServicesNavigator({
    super.key,
    required this.onTitleChange,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Services(onTitleChange: onTitleChange),
        );
      },
    );
  }
}

class ProfileNavigator extends StatelessWidget {
  final Function(String) onTitleChange;
  final GlobalKey<NavigatorState> navigatorKey;

  const ProfileNavigator({
    super.key,
    required this.onTitleChange,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Profile(onTitleChange: onTitleChange),
        );
      },
    );
  }
}
