import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassChangePassScreen extends StatefulWidget {
  const ForgotPassChangePassScreen({super.key});

  @override
  State<ForgotPassChangePassScreen> createState() =>
      _ForgotPassChangePassScreenState();
}

class _ForgotPassChangePassScreenState extends State<ForgotPassChangePassScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // FocusNodes to track which field is active for the blue border
  final FocusNode _passFocus = FocusNode();
  final FocusNode _confirmPassFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    // Listen to focus changes to trigger UI rebuild for border color and thickness
    _passFocus.addListener(() => setState(() {}));
    _confirmPassFocus.addListener(() => setState(() {}));
  }

  void _validateForm() {
    setState(() {
      _canSave = _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              // Logic: Blue border if focused, otherwise light gray
              color: focusNode.hasFocus ? const Color(0xFF2B6FD4) : Colors.black12,
              // Thickness changes to 1.5 when clicked/focused
              width: focusNode.hasFocus ? 1.0 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.black45,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B6FD4),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 30),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 125,
                    height: 125,
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
                          Icons.description_outlined, size: 45, color: Color(0xFF2B6FD4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Enter your new password.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 40),

                            _buildPasswordField(
                              label: 'NEW PASSWORD',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              focusNode: _passFocus,
                              obscureText: _obscurePassword,
                              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),

                            const SizedBox(height: 20),

                            _buildPasswordField(
                              label: 'CONFIRM PASSWORD',
                              hint: 'Confirm your password',
                              controller: _confirmPasswordController,
                              focusNode: _confirmPassFocus,
                              obscureText: _obscureConfirmPassword,
                              onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),

                            const SizedBox(height: 40),

                            // Save Changes Button with Shadow Logic
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: _canSave ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ] : [], // Shadow disappears when passwords don't match
                              ),
                              child: ElevatedButton(
                                onPressed: _canSave ? () {
                                  // Implementation for saving password
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  // Logic: Blue if valid, Gray if not
                                  backgroundColor: _canSave ? const Color(0xFF2B6FD4) : const Color(0xFFCCCCCC),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0, // Handled by Container
                                ),
                                child: Text(
                                  'Save Changes',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _canSave ? Colors.white : Colors.black45,
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