import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docsease/custom_button.dart';
import 'package:docsease/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/app_modals.dart';
import 'package:docsease/forgotpass_recoverycode.dart';
import 'package:docsease/custom_textfield.dart';
import 'package:docsease/navigator_transition.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() => _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseServices _authService = FirebaseServices();

  bool invalidInput = false;
  bool isLoading = false;

  Timer? _debounce;
  bool _emailNotFound = false;

  String _generateRecoveryCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<bool> _sendEmailJSRecovery(String targetEmail, String recoveryCode) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': 'service_e6xjj5b',
          'template_id': 'template_1u1on8f',
          'user_id': 'MhxD0XeexOnz61prP',
          'accessToken': 'ZwFXbNZRrkVkNGK4YFHWm',
          'template_params': {'to_email': targetEmail, 'recovery_code': recoveryCode},
        }),
      );
      print('EmailJS Status Code: ${response.statusCode}');
      print('EmailJS Response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print("EmailJS Error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 243, 243, 1),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(color: const Color.fromRGBO(32, 87, 206, 1.0)),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      // --- Fixed Header Section ---
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(10, 49, 104, 1),
                                  width: 1.0,
                                ),
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/docsease_logo.png",
                                  height: 105,
                                  width: 105,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.description_outlined,
                                    size: 40,
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
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Center(
                                          child: Text(
                                            'Enter Email Address',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Center(
                                          child: Text(
                                            'Input your registered email address below so we can verify your identity',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 50),
                                      CustomTextField(
                                        inputLabel: 'EMAIL ADDRESS',
                                        inputHint: 'Enter your email',
                                        inputType: TextInputType.emailAddress,
                                        liveSuccessValidation: true,
                                        controller: _emailController,
                                        validator: (value) {
                                          final emailRegex = RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$',
                                          );
                                          if (value.isEmpty || !emailRegex.hasMatch(value.trim())) {
                                            return value.isEmpty
                                                ? 'Please fill the required field.'
                                                : 'Please enter a valid email (e.g., name@example.com).';
                                          }
                                          if (_emailNotFound) {
                                            return 'This email does not exist.';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() => invalidInput = false);

                                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                                          _debounce = Timer(
                                            const Duration(milliseconds: 300),
                                            () async {
                                              final emailRegex = RegExp(
                                                r'^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$',
                                              );
                                              if (emailRegex.hasMatch(value.trim())) {
                                                bool exists = await _authService.isEmailTaken(
                                                  value.trim(),
                                                );
                                                setState(() => _emailNotFound = !exists);
                                              }
                                            },
                                          );
                                        },
                                        forceValidate: invalidInput || _emailNotFound,
                                      ),
                                      const SizedBox(height: 25),
                                      CustomButton(
                                        buttonText: 'Proceed',
                                        isLoading: isLoading,
                                        isButtonEnabled: _emailController.text.isNotEmpty,
                                        onTapAction: () async {
                                          final emailRegex = RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$',
                                          );
                                          bool isEmailValid = emailRegex.hasMatch(
                                            _emailController.text.trim(),
                                          );

                                          if (!isEmailValid) {
                                            setState(() => invalidInput = true);
                                            return;
                                          }

                                          try {
                                            setState(() => isLoading = true);
                                            String targetEmail = _emailController.text.trim();

                                            bool exists = await _authService.isEmailTaken(
                                              _emailController.text.trim(),
                                            );

                                            if (!exists) {
                                              if (mounted) {
                                                setState(() {
                                                  _emailNotFound = true;
                                                  invalidInput = true;
                                                  isLoading = false;
                                                });
                                              }
                                              return;
                                            }

                                            String recoveryCode = _generateRecoveryCode();
                                            await FirebaseFirestore.instance
                                                .collection('recovery_codes')
                                                .doc(targetEmail) // Use email as the document ID
                                                .set({
                                                  'code': recoveryCode,
                                                  'createdAt': FieldValue.serverTimestamp(),
                                                });

                                            bool emailSent = await _sendEmailJSRecovery(
                                              targetEmail,
                                              recoveryCode,
                                            );

                                            if (mounted) {
                                              setState(() => isLoading = false);

                                              if (emailSent) {
                                                await CheckEmailModal.show(
                                                  context,
                                                  onPrimary: () {
                                                    Navigator.of(context).pop();
                                                    _emailController.clear();
                                                    setState(() {
                                                      invalidInput = false;
                                                      _emailNotFound = false;
                                                    });
                                                    Navigator.push(
                                                      context,
                                                      SlideRoute(
                                                        page: ForgotPasswordRecoveryScreen(
                                                          targetEmail: targetEmail,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Failed to send email. Please check your internet and try again.",
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() {
                                                invalidInput = true;
                                                isLoading = false;
                                              });
                                            }
                                          }
                                        },
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
                                      const SizedBox(height: 10),
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
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
