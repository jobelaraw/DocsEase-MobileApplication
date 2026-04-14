import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services.dart';


class AppStart extends StatelessWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── App Logo ──
              Image.asset(
                'assets/appstart_logo.png', 
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 32),

              //Welcome Title
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

              //Subtitle 
              Text(
                'Your smart assistant for government\ndocuments. Navigate complex forms with ease',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.55,
                ),
              ),

              const Spacer(flex: 2),

              //Get Started Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to Sign In / Sign Up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B73E0),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Get Started!',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              //Continue as Guest Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Services()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B73E0),
                    elevation: 6,
                    side: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Continue as Guest',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Open Terms of Services
                        },
                    ),
                    const TextSpan(text: ' and\n'),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF3B73E0),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Open Privacy Policy
                        },
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
    );
  }
}