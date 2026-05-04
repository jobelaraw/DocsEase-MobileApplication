import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgotpass_changepass.dart';

class ForgotPasswordRecoveryScreen extends StatefulWidget {
  const ForgotPasswordRecoveryScreen({super.key});

  @override
  State<ForgotPasswordRecoveryScreen> createState() =>
      _ForgotPasswordRecoveryScreenState();
}

class _ForgotPasswordRecoveryScreenState extends State<ForgotPasswordRecoveryScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isComplete = false;

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
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? const Color(0xFF2B6FD4)
              : Colors.black.withOpacity(0.2),
          width: _focusNodes[index].hasFocus ? 1.0 : 1.0,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B6FD4),
      body: SafeArea(
        child: Column(
          children: [
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
                          Icons.description_outlined, size: 50, color: Color(0xFF2B6FD4),
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

                            const SizedBox(height: 40),

                            // --- VERIFY BUTTON WITH SHADOW ---
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: _isComplete ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ] : [],
                              ),
                              child: ElevatedButton(
                                onPressed: _isComplete ? () {
                                  // --- ADDED NAVIGATION HERE ---
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ForgotPassChangePassScreen(),
                                    ),
                                  );
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isComplete
                                      ? const Color(0xFF2B6FD4)
                                      : const Color(0xFFCCCCCC),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0, // Shadow handled by Container
                                ),
                                child: Text(
                                  'Verify',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _isComplete ? Colors.white : Colors.black45,
                                  ),
                                ),
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
    );
  }
}