import 'package:cloud_functions/cloud_functions.dart';
import 'package:docsease/custom_button.dart';
import 'package:docsease/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/app_modals.dart';
import 'package:docsease/forgotpass_recoverycode.dart';
import 'package:docsease/custom_textfield.dart';
import 'package:docsease/navigator_transition.dart';
import 'dart:async';
import 'package:docsease/network_check.dart';

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

  Future<String> _requestRecoveryCode(String email) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendRecoveryCode')
          .call({'email': email})
          .timeout(const Duration(seconds: 30));
      return 'ok';
    } on FirebaseFunctionsException catch (e) {
      debugPrint('sendRecoveryCode error: ${e.code} ${e.message}');
      switch (e.code) {
        case 'not-found':
          return 'not-found';
        case 'resource-exhausted':
          return 'cooldown:${e.message ?? 'Please wait before requesting another code.'}';
        case 'unavailable':
          final details = e.details;
          final status = details is Map ? details['status'] : null;
          if (status == null && !await NetworkCheck.hasInternet()) return 'offline';
          return 'failed:${status ?? e.code}';
        default:
          return 'failed:${e.code}';
      }
    } on TimeoutException {
      return 'offline';
    } catch (e) {
      debugPrint('sendRecoveryCode error: $e');
      return 'failed:error';
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
                              'GaBayan',
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
                                                if (!await NetworkCheck.hasInternet()) return;
                                                try {
                                                  final exists = await _authService.isEmailRegistered(value.trim());
                                                  if (!mounted) return;
                                                  setState(() => _emailNotFound = !exists);
                                                } catch (_) {}
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
                                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$');
                                          bool isEmailValid = emailRegex.hasMatch(_emailController.text.trim());

                                          if (!isEmailValid) {
                                            setState(() => invalidInput = true);
                                            return;
                                          }

                                          setState(() => isLoading = true);
                                          if (!await NetworkCheck.hasInternet()) {
                                            if (mounted) {
                                              setState(() => isLoading = false);
                                              NoInternetModal.show(context);
                                            }
                                            return;
                                          }

                                          try {
                                            setState(() => isLoading = true);

                                            String targetEmail = _emailController.text.trim();
                                            final sendResult = await _requestRecoveryCode(targetEmail);
                                            final bool emailSent = sendResult == 'ok';

                                            if (sendResult == 'not-found') {
                                              if (mounted) {
                                                setState(() {
                                                  isLoading = false;
                                                  _emailNotFound = true;
                                                  invalidInput = true;
                                                });
                                              }
                                              return;
                                            }

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
                                                      SlideRoute(page: ForgotPasswordRecoveryScreen(targetEmail: targetEmail)),
                                                    );
                                                  },
                                                );
                                              } else if (sendResult == 'offline') {
                                                NoInternetModal.show(context);
                                              } else if (sendResult.startsWith('cooldown:')) {
                                                AuthErrorModal.show(
                                                  context,
                                                  title: 'Please Wait',
                                                  subtitle: sendResult.replaceFirst('cooldown:', ''),
                                                );
                                              } else {
                                                AuthErrorModal.show(
                                                  context,
                                                  title: 'Failed to Send',
                                                  subtitle:
                                                  'We could not send the recovery code. Please try again later. (${sendResult.replaceFirst('failed:', 'Error ')})',
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            final stillOnline = await NetworkCheck.hasInternet();
                                            if (mounted) {
                                              setState(() {
                                                isLoading = false;
                                                if (stillOnline) invalidInput = true;
                                              });
                                              if (!stillOnline) NoInternetModal.show(context);
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