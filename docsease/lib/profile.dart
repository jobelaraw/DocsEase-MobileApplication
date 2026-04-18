import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/edit_profile.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(230, 246, 255, 1.0),
      body: Stack(
        children: [
          // Blue Header Section
          Container(
            height: MediaQuery.of(context).size.height * 0.37,
            width: double.infinity,
            color: const Color.fromRGBO(32, 87, 206, 1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Profile",
                  style: TextStyle(
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
                        backgroundImage: AssetImage('assets/default_profile.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector( // <--- 1. Add this to detect the tap
                        onTap: () {
                          // 2. This pushes the EditProfile screen onto the stack
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(
                                onBack: () => Navigator.pop(context), // This makes the back button work
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            // Optional: Add a small shadow so it's easier to see the button
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/camera_icon.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector( // <--- Add this to detect the tap
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'John John',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Citizen User',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700 ,
                    color: Colors.white70,
                  ),
                ),

              ],
            ),
          ),

          // Transaction Card
          Align(
            alignment: const Alignment(0, 0.1),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
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
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transaction History",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800, // Extra bold like mockup
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            color: Color.fromRGBO(32, 87, 206, 1.0),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Transaction Items
                  _buildTransactionItem(
                    iconPath: 'assets/baby_icon.png', // Baby icon for birth certificate
                    title: "Birth Certificate",
                    status: "In Progress",
                    statusColor: const Color(0xFFFF7043), // Muted Orange
                    progress: 0.4,
                    iconBg: const Color(0xFFE0F2F1),
                    onTap: () {
                      print("Navigating to Birth Certificate Panel");
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => BirthCertificatePanel()));
                    },
                  ),
                  const Divider(height: 40, thickness: 0.8),
                  _buildTransactionItem(
                    iconPath:'assets/heart_icon.png',
                    title: "Marriage Certificate",
                    status: "Completed",
                    statusColor: const Color(0xFF4CAF50), // Vibrant Green
                    showProgress: false,
                    iconBg: const Color(0xFFFCE4EC),
                    onTap: () {
                      print("Navigating to Marriage Certificate Panel");
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => MarriageCertificatePanel()));
                    },
                  ),
                  const Divider(height: 30, thickness: 0.8),
                  _buildTransactionItem(
                    iconPath: 'assets/nationalID_icon.png',
                    title: "National ID",
                    status: "Completed",
                    statusColor: const Color(0xFF4CAF50),
                    showProgress: false,
                    iconBg: const Color(0xFFDCEDC8),
                    onTap: () {
                      print("Navigating to National ID Panel");
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => NationalIDPanel()));
                    },
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String iconPath,
    required String title,
    required String status,
    required Color statusColor,
    double progress = 0.0,
    bool showProgress = true,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
    child: Column(
      children: [
        Row(
          children: [
            // Colored Icon Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 15),
            // Title and Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    status,
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Right Arrow and Percentage
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.chevron_right, color: Colors.black87, size: 28),
                if (showProgress)
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (showProgress) ...[
          const SizedBox(height: 10),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
        ]
      ],
    ),
      ),
    );
  }
}