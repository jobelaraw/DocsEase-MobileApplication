import 'dart:math';
import 'package:docsease/authentication.dart';
import 'package:docsease/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'navigator_transition.dart';

class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  bool _isGuestLoading = false;
  bool _guestTriggerFired = false;

  @override
  void initState() {
    super.initState();
    // Check if we need to auto-trigger when mounting
    var authBox = Hive.box('auth_box');
    if (authBox.get('triggerGuestAnimation', defaultValue: false)) {
      authBox.put('triggerGuestAnimation', false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleGuestLogin();
      });
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() {
      _isGuestLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    var authBox = Hive.box('auth_box');

    if (authBox.get('guestId') == null) {
      String randomDigits = (Random().nextInt(900000000) + 1000000000).toString();
      authBox.put('guestId', 'Guest_$randomDigits');
    }
    authBox.put('continueGuest', true);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        SlideRoute(page: const SideBar(isGuest: true)),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppStart now listens to the Hive box in real-time!
    return ValueListenableBuilder(
      valueListenable: Hive.box('auth_box').listenable(keys: ['triggerGuestAnimation']),
      builder: (context, box, child) {
        // If Authentication sets the flag to true, instantly trigger the loader!
        if (box.get('triggerGuestAnimation', defaultValue: false) && !_guestTriggerFired) {
          _guestTriggerFired = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              box.put('triggerGuestAnimation', false);
              _guestTriggerFired = false;
              _handleGuestLogin();
            }
          });
        }
        return child!;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // ── App Logo ──
                      Image.asset(
                        'assets/docsease_logo.png',
                        width: MediaQuery.of(context).size.width < 400 ? 180 : 200,
                        height: MediaQuery.of(context).size.width < 400 ? 180 : 200,
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Welcome to\nDocsEase!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Your smart assistant for government\ndocuments. Navigate complex forms with ease',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          height: 1.55,
                        ),
                      ),

                      const Spacer(flex: 3),

                      //Get Started Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, SlideRoute(page: const Authentication()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B73E0),
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Get Started!',
                              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      //Continue as Guest Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isGuestLoading ? null : _handleGuestLogin,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B73E0),
                            elevation: 6,
                            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: _isGuestLoading
                              ? SizedBox(
                                  height: 40,
                                  child: Transform.scale(
                                    scale: 1.5,
                                    child: Transform.translate(
                                      offset: const Offset(0, -7),
                                      child: Lottie.asset('assets/Loading.json'),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Continue as Guest',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF3B73E0),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Terms & Privacy ──
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            height: 1.6,
                          ),
                          children: [
                            const TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms of Services',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF3B73E0),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF3B73E0),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
