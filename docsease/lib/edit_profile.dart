import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfile extends StatefulWidget {
  final VoidCallback onBack;

  const EditProfile({super.key, required this.onBack});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(230, 246, 255, 1.0),
      body: Stack(
        children: [
          // Blue Header Section
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            color: const Color.fromRGBO(32, 87, 206, 1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  "Edit Profile",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(
                          'assets/default_profile.png',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/camera_icon.png',
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  'johnjohn@gmail.com',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Edit Form Card
          Align(
            alignment: const Alignment(0, 0.5),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("USERNAME"),
                  _buildTextField(hintText: "johnjohn"),
                  const SizedBox(height: 20),
                  _buildLabel("NEW PASSWORD"),
                  _buildTextField(
                    hintText: "••••••••••••••",
                    isPassword: true,
                    obscureText: _obscureNewPassword,
                    onToggle: () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("CONFIRM PASSWORD"),
                  _buildTextField(
                    hintText: "••••••••••••••",
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(
                          59,
                          115,
                          224,
                          1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.4),
                      ),
                      child: Text(
                        "Save Changes",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back Button
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: widget.onBack,
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the small grey uppercase labels
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.black54,
        ),
      ),
    );
  }

  // Helper to build the TextFields
  Widget _buildTextField({
    required String hintText,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black26),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color.fromRGBO(32, 87, 206, 1.0)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                onPressed: onToggle,
              )
            : null,
      ),
    );
  }
}
