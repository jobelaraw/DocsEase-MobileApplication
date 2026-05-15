import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docsease/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/forgotpass_changepass.dart';

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

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(_checkCompletion);
      _focusNodes[i].addListener(() {
        setState(() {});
      });
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
              _controllers[index - 1].clear(); // Delete the letter in the previous box
              _focusNodes[index - 1].requestFocus(); // Jump focus to the previous box
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
            if (_hasError) {
              setState(() => _hasError = false);
            }

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
      backgroundColor: const Color(0xFF2B6FD4),
      body: SafeArea(
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
                            border: Border.all(color: Color.fromRGBO(10, 49, 104, 1), width: 1.0),
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
                                children: [
                                  const SizedBox(height: 60),
                                  Text(
                                    'Enter recovery code sent to your email.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (index) => _buildCodeBox(index)),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    switchInCurve:
                                        Curves.easeOutBack, // Gives it that satisfying bounce!
                                    switchOutCurve: Curves.easeIn,
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return SizeTransition(
                                        sizeFactor: animation,
                                        axisAlignment:
                                            -1.0, // Anchors the animation to the bottom of the text field
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.5),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: FadeTransition(opacity: animation, child: child),
                                        ),
                                      );
                                    },
                                    child: _hasError
                                        ? Padding(
                                            key: ValueKey('error'),
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
                                            key: ValueKey('complete'),
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
                                        setState(() {
                                          _isComplete = false;
                                        });
                                        return;
                                      }

                                      try {
                                        setState(() => isLoading = true);

                                        var docSnapshot = await FirebaseFirestore.instance
                                            .collection('recovery_codes')
                                            .doc(widget.targetEmail)
                                            .get();

                                        if (!docSnapshot.exists ||
                                            docSnapshot.data()?['code'] != enteredCode) {
                                          setState(() {
                                            _hasError = true;
                                            isLoading = false;
                                          });
                                          return;
                                        }

                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ForgotPassChangePassScreen(
                                                targetEmail: widget.targetEmail,
                                                recoveryCode: enteredCode,
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          setState(() {
                                            _isComplete = false;
                                            isLoading = false;
                                            _hasError = true;
                                          });
                                        }
                                      }
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
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
