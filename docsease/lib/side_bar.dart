import 'package:docsease/services.dart';
import 'package:docsease/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SideBar> {
  int selectedIndex = 0;

  // List of screens that's gonna be used
  final List<Widget> screens = [Services(), Services(), Services(), Settings()];

  // List of titles along with the screens
  late final List<String> titles = ['Services', 'Profile', 'About', 'Settings'];

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                splashRadius: 10.0,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: ImageIcon(
                  AssetImage('assets/hamburger_icon.png'),
                  size: 20,
                  color: Colors.white,
                ),
              );
            },
          ),
          title: Text(
            titles[selectedIndex],
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color.fromRGBO(32, 87, 206, 1.0),
          surfaceTintColor: Colors.transparent,
          elevation: 1.0,
          shadowColor: Colors.black.withOpacity(0.3),
          toolbarHeight: 70,
        ),
        drawer: Drawer(
          width: 250,
          backgroundColor: Color.fromRGBO(230, 246, 255, 1.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(0.0),
              bottomRight: Radius.circular(0.0),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 172,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(32, 87, 206, 1.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const ImageIcon(
                          AssetImage('assets/close_icon.png'),
                          size: 17,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    ClipOval(
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
                      imagePath: 'assets/home_icon.png',
                      optionName: 'Home',
                      isSelected: selectedIndex == 0,
                      onTapAction: () {
                        setState(() {
                          selectedIndex = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 13),
                    SideBarOption(
                      imagePath: 'assets/profile_icon.png',
                      optionName: 'Profile',
                      isSelected: selectedIndex == 1,
                      onTapAction: () {
                        setState(() {
                          selectedIndex = 0; // Change this to 1 later on
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 13),
                    SideBarOption(
                      imagePath: 'assets/about_icon.png',
                      optionName: 'About',
                      isSelected: selectedIndex == 2,
                      onTapAction: () {
                        setState(() {
                          selectedIndex = 0; // Change this to 2 later on
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 13),
                    SideBarOption(
                      imagePath: 'assets/settings_icon.png',
                      optionName: 'Settings',
                      isSelected: selectedIndex == 3,
                      onTapAction: () {
                        setState(() {
                          selectedIndex = 0; // Change this to 3 later on
                        });
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
