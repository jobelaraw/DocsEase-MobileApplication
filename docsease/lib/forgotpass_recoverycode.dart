import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:docsease/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/app_modals.dart';
import 'package:docsease/forgotpass_changepass.dart';
import 'package:docsease/navigator_transition.dart';

class ForgotPasswordRecoveryScreen extends StatefulWidget {
  final String targetEmail;

  const ForgotPasswordRecoveryScreen({super.key, required this.targetEmail});

  @override
  State<ForgotPasswordRecoveryScreen> createState() => _ForgotPasswordRecoveryScreenState();
}

class _ForgotPasswordRecoveryScreenState extends State<ForgotPasswordRecoveryScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isComplete = false;
  bool _hasError = false;
  bool isLoading = false;
  bool _isResending = false;

  static const int _resendCooldown = 60;
  int _resendSecondsLeft = _resendCooldown;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(_checkCompletion);
      _focusNodes[i].addListener(() {
        setState(() {});
      });
    }
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _resendSecondsLeft = _resendCooldown);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSecondsLeft = 0);
      } else {
        if (mounted) setState(() => _resendSecondsLeft--);
      }
    });
  }

  String _formatResendTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs seconds';
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendRecoveryCode')
          .call({'email': widget.targetEmail});
      if (mounted) {
        for (var c in _controllers) c.clear();
        setState(() {
          _hasError = false;
          _isComplete = false;
        });
        await ResendCodeModal.show(context, onPrimary: () => Navigator.of(context).pop());
        _startResendTimer();
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('resend error: ${e.code} ${e.message}');
      if (mounted) {
        AuthErrorModal.show(
          context,
          title: e.code == 'resource-exhausted' ? 'Please Wait' : 'Failed to Send',
          subtitle: e.code == 'resource-exhausted'
              ? (e.message ?? 'Please wait before requesting another code.')
              : 'We could not send the recovery code. Please try again later.',
        );
      }
    } catch (e) {
      debugPrint('resend error: $e');
      if (mounted) {
        AuthErrorModal.show(
          context,
          title: 'Failed to Send',
          subtitle: 'We could not send the recovery code. Please try again later.',
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _checkCompletion() {
    bool complete = _controllers.every((c) => c.text.isNotEmpty);
    if (complete != _isComplete) {
      setState(() {
        _isComplete = complete;
        if (!complete) _hasError = false;
      });
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  Widget _buildCodeBox(int index) {
    Color bgColor = Colors.white;
    Color borderColor = _focusNodes[index].hasFocus
        ? const Color(0xFF2B6FD4)
        : Colors.black.withOpacity(0.2);

    if (_hasError) {
      bgColor = Colors.red.withOpacity(0.03);
      borderColor = Colors.red;
    } else if (_isComplete) {
      bgColor = Colors.green.withOpacity(0.03);
      borderColor = Colors.green;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: _focusNodes[index].hasFocus || _isComplete || _hasError ? 1.5 : 1.0,
        ),
      ),
      child: Focus(
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _controllers[index - 1].clear();
              _focusNodes[index - 1].requestFocus();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            UpperCaseTextFormatter(),
          ],
          maxLength: 1,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          decoration: const InputDecoration(counterText: "", border: InputBorder.none),
          onChanged: (value) {
            if (_hasError) setState(() => _hasError = false);
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            }
          },
        ),
      ),
    );
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
                                  color: const Color.fromRGBO(10, 49, 104, 1),
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
                                            'Enter OTP to Verify Your Identity',
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
                                            'Please type the 6-digit verification code sent to your registered email address.',
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: List.generate(6, (index) => _buildCodeBox(index)),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 500),
                                        switchInCurve: Curves.easeOutBack,
                                        switchOutCurve: Curves.easeIn,
                                        transitionBuilder:
                                            (Widget child, Animation<double> animation) {
                                          return SizeTransition(
                                            sizeFactor: animation,
                                            axisAlignment: -1.0,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 0.5),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            ),
                                          );
                                        },
                                        child: _hasError
                                            ? Padding(
                                          key: const ValueKey('error'),
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Center(
                                            child: Text(
                                              'Invalid code. Please try again.',
                                              style: GoogleFonts.inter(
                                                color: const Color.fromRGBO(255, 100, 100, 1),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                            : _isComplete
                                            ? Padding(
                                          key: const ValueKey('complete'),
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Center(
                                            child: Text(
                                              'Valid recovery code.',
                                              style: GoogleFonts.inter(
                                                color: Colors.green,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                            : const SizedBox.shrink(key: ValueKey('empty')),
                                      ),
                                      const SizedBox(height: 40),
                                      CustomButton(
                                        buttonText: 'Verify',
                                        isLoading: isLoading,
                                        isButtonEnabled: _isComplete,
                                        onTapAction: () async {
                                          String enteredCode = _controllers.map((c) => c.text).join();

                                          if (!_isComplete) {
                                            setState(() => _isComplete = false);
                                            return;
                                          }

                                          try {
                                            setState(() => isLoading = true);

                                            try {
                                              await FirebaseFunctions.instance
                                                  .httpsCallable('verifyRecoveryCode')
                                                  .call({'email': widget.targetEmail, 'code': enteredCode});
                                            } on FirebaseFunctionsException catch (e) {
                                              final codeProblem = e.code == 'failed-precondition' || e.code == 'resource-exhausted';
                                              if (mounted) {
                                                setState(() {
                                                  isLoading = false;
                                                  _hasError = e.code == 'permission-denied' || codeProblem;
                                                });
                                                if (e.code != 'permission-denied') {
                                                  AuthErrorModal.show(
                                                    context,
                                                    title: codeProblem ? 'Code Not Valid' : 'Something Went Wrong',
                                                    subtitle: codeProblem
                                                        ? (e.message ?? 'Please request a new code.')
                                                        : 'Please check your connection and try again.',
                                                  );
                                                }
                                              }
                                              return;
                                            }

                                            if (mounted) {
                                              setState(() => isLoading = false);

                                              await VerifiedModal.show(
                                                context,
                                                onPrimary: () {
                                                  Navigator.of(context).pop();
                                                  for (var c in _controllers) c.clear();
                                                  setState(() {
                                                    _isComplete = false;
                                                    _hasError = false;
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    SlideRoute(
                                                      page: ForgotPassChangePassScreen(
                                                        targetEmail: widget.targetEmail,
                                                        recoveryCode: enteredCode,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() {
                                                isLoading = false;
                                                _isComplete = false;
                                                _hasError = true;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: _isResending ? null : _resendCode,
                                              child: _isResending
                                                  ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                                  : RichText(
                                                text: TextSpan(
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                  children: [
                                                    const TextSpan(
                                                      text: "Didn't receive a code? ",
                                                    ),
                                                    TextSpan(
                                                      text: 'Resend code',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: _resendSecondsLeft > 0
                                                            ? const Color(
                                                          0xFF2B6FD4,
                                                        ).withOpacity(0.4)
                                                            : const Color(0xFF2B6FD4),
                                                        decoration: TextDecoration.underline,
                                                        decorationColor:
                                                        _resendSecondsLeft > 0
                                                            ? const Color(
                                                          0xFF2B6FD4,
                                                        ).withOpacity(0.4)
                                                            : const Color(0xFF2B6FD4),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (_resendSecondsLeft > 0) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                _formatResendTime(_resendSecondsLeft),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}