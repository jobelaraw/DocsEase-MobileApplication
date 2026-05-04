import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgotpass_recoverycode.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });

    _emailController.addListener(() {
      setState(() {
        _isButtonEnabled = _emailController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B6FD4),
      body: SafeArea(
        child: Column(
          children: [
            // --- Fixed Header Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/docsease_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.description_outlined,
                          size: 50,
                          color: Color(0xFF2B6FD4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'DocsEase',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Smart Assisstant for\ngovernment procedures.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // --- Bottom Panel ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7EEF0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Forgot Password',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2B6FD4),
                              ),
                            ),
                            const SizedBox(height: 11),
                            Container(
                              height: 1.5,
                              width: 250,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B6FD4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 0, 26, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 22),
                            Center(
                              child: Text(
                                'Enter your registered email address below.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            Text(
                              'EMAIL ADDRESS',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _isEmailFocused
                                      ? const Color(0xFF2B6FD4)
                                      : Colors.black.withOpacity(0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: TextField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // --- BUTTON WITH SHADOW EFFECT ---
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: _isButtonEnabled ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4), // Shadow position
                                  ),
                                ] : [], // No shadow when disabled
                              ),
                              child: ElevatedButton(
                                onPressed: _isButtonEnabled
                                    ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordRecoveryScreen(),
                                    ),
                                  );
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isButtonEnabled
                                      ? const Color(0xFF2B6FD4)
                                      : const Color(0xFFCCCCCC),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0, // Set to 0 because we are using BoxDecoration for custom shadow
                                ),
                                child: Text(
                                  'Proceed',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _isButtonEnabled ? Colors.white : Colors.black38,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 80),

                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Don't remember your email?",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                      children: [
                                        const TextSpan(text: "Contact us at "),
                                        TextSpan(
                                          text: 'docsease.com',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2B6FD4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
          ],
        ),
      ),
    );
  }
}