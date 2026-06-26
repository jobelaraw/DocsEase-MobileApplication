import 'package:docsease/app_modals.dart';
import 'package:docsease/authentication.dart';
import 'package:docsease/custom_button.dart';
import 'package:docsease/custom_textfield.dart';
import 'package:docsease/navigator_transition.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassChangePassScreen extends StatefulWidget {
  final String targetEmail;
  final String recoveryCode;

  const ForgotPassChangePassScreen({
    super.key,
    required this.targetEmail,
    required this.recoveryCode,
  });

  @override
  State<ForgotPassChangePassScreen> createState() => _ForgotPassChangePassScreenState();
}

class _ForgotPassChangePassScreenState extends State<ForgotPassChangePassScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String passwordText = '';
  bool hasStrongPassword = false;
  bool invalidInput = false;
  bool isLoading = false;

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
                      // Header Section
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
                            const SizedBox(height: 8),
                            Text(
                              'DocsEase',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Smart Assistant for\ngovernment procedures.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main White Panel
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
                                            'Enter Your New Password',
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
                                            'Set a strong new password to secure your account.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),

                                      CustomTextField(
                                        inputLabel: 'PASSWORD',
                                        inputHint: 'Enter your password',
                                        inputType: TextInputType.visiblePassword,
                                        isPassword: true,
                                        isLoginPass: false,
                                        controller: _passwordController,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please fill the required field.';
                                          }
                                          bool hasLength = value.length >= 8;
                                          bool hasSymbol = RegExp(
                                            r'[^a-zA-Z0-9\s]',
                                          ).hasMatch(value);
                                          bool hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
                                          bool hasNumber = RegExp(r'[0-9]').hasMatch(value);

                                          int score =
                                              (hasLength ? 1 : 0) +
                                              (hasSymbol ? 1 : 0) +
                                              (hasUppercase ? 1 : 0) +
                                              (hasNumber ? 1 : 0);

                                          if (score < 4) {
                                            return 'Please meet all the password requirements.';
                                          }
                                          hasStrongPassword = true;
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            passwordText = value;
                                            invalidInput = false;
                                          });
                                        },
                                        forceValidate: invalidInput,
                                        receivedPassword: passwordText,
                                      ),
                                      const SizedBox(height: 20),
                                      CustomTextField(
                                        inputLabel: 'CONFIRM PASSWORD',
                                        inputHint: 'Confirm your password',
                                        inputType: TextInputType.visiblePassword,
                                        isPassword: true,
                                        isLoginPass: false,
                                        controller: _confirmPasswordController,
                                        validator: (value) {
                                          if (value.isEmpty || value != _passwordController.text) {
                                            return value.isEmpty
                                                ? 'Please fill the required field.'
                                                : 'Passwords do not match. Please try again.';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            invalidInput = false;
                                          });
                                        },
                                        forceValidate: invalidInput,
                                      ),

                                      const SizedBox(height: 40),

                                      CustomButton(
                                        buttonText: 'Save Changes',
                                        isLoading: isLoading,
                                        isButtonEnabled:
                                            _passwordController.text.isNotEmpty &&
                                            _confirmPasswordController.text.isNotEmpty,
                                        onTapAction: () async {
                                          bool isPasswordValid =
                                              _passwordController.text.isNotEmpty &&
                                              hasStrongPassword;
                                          bool isConfirmValid =
                                              _confirmPasswordController.text.isNotEmpty &&
                                              _confirmPasswordController.text ==
                                                  _passwordController.text;
                                          if (!isPasswordValid || !isConfirmValid) {
                                            setState(() => invalidInput = true);
                                            return;
                                          }

                                          await ConfirmChangesModal.show(
                                            context,
                                            onPrimary: () async {
                                              Navigator.of(context).pop();

                                              try {
                                                setState(() => isLoading = true);

                                                print("--- PRE-FLIGHT CHECK ---");
                                                print("Target Email: '${widget.targetEmail}'");
                                                print("Recovery Code: '${widget.recoveryCode}'");
                                                print(
                                                  "New Password: '${_passwordController.text.trim()}'",
                                                );
                                                print("------------------------");

                                                HttpsCallable callable = FirebaseFunctions.instance
                                                    .httpsCallable('resetUserPassword');
                                                await callable.call({
                                                  'email': widget.targetEmail,
                                                  'otp': widget.recoveryCode,
                                                  'newPassword': _passwordController.text.trim(),
                                                });

                                                if (mounted) {
                                                  setState(() => isLoading = false);
                                                  await ChangesSavedModal.show(
                                                    context,
                                                    onPrimary: () {
                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pushAndRemoveUntil(
                                                        SlideRoute(page: const Authentication()),
                                                        (route) => route.isFirst,
                                                      );
                                                    },
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  setState(() {
                                                    invalidInput = true;
                                                    isLoading = false;
                                                  });
                                                }
                                                print("Cloud Function Error: $e");
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Error: ${e.toString()}"),
                                                    backgroundColor: Colors.red,
                                                    duration: const Duration(seconds: 5),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 30),
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
