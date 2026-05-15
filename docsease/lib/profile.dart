import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/edit_profile.dart';

class Profile extends StatefulWidget {
  final Function(String) onTitleChange;

  const Profile({super.key, required this.onTitleChange});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseAuth.instance.currentUser != null
                      ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    String currentUsername = '...';
                    String currentProfile = 'assets/default_profile.png';

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      currentUsername = data['username'] ?? 'Guest Account';
                      currentProfile = data['profile_img'] ?? 'assets/default_profile.png';
                    }

                    bool hasDefaultProfile = currentProfile == 'assets/default_profile.png';

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              child: ClipOval(
                                child: hasDefaultProfile
                                    ? Image.asset(
                                        currentProfile,
                                        width: 95,
                                        height: 95,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        currentProfile,
                                        width: 95,
                                        height: 95,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                // <--- 1. Add this to detect the tap
                                onTap: () {
                                  widget.onTitleChange('Edit Profile');
                                  // 2. This pushes the EditProfile screen onto the stack
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const EditProfile()),
                                  ).then((_) {
                                    widget.onTitleChange('Profile');
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.circle,
                                    // Optional: Add a small shadow so it's easier to see the button
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/edit_icon.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          // <--- Add this to detect the tap
                          onTap: () {
                            widget.onTitleChange('Edit Profile');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EditProfile()),
                            ).then((_) {
                              widget.onTitleChange('Profile');
                            });
                          },
                          child: Text(
                            currentUsername,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Text(
                          'Citizen User',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // Transaction Card
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Text(
                        "Transaction History",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Scrollable Transaction Items
                      Flexible(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                _buildTransactionItem(
                                  iconPath: 'assets/baby_icon.png',
                                  title: "Birth Certificate",
                                  status: "In Progress",
                                  statusColor: const Color(0xFFFF7043),
                                  progress: 0.4,
                                  iconBg: const Color(0xFFE0F2F1),
                                  onTap: () {
                                    print("Navigating to Birth Certificate Panel");
                                  },
                                ),
                                const Divider(height: 40, thickness: 0.8),
                                _buildTransactionItem(
                                  iconPath: 'assets/heart_icon.png',
                                  title: "Marriage Certificate",
                                  status: "Completed",
                                  statusColor: const Color(0xFF4CAF50),
                                  showProgress: false,
                                  iconBg: const Color(0xFFFCE4EC),
                                  onTap: () {
                                    print("Navigating to Marriage Certificate Panel");
                                  },
                                ),
                                const Divider(height: 40, thickness: 0.8),
                                _buildTransactionItem(
                                  iconPath: 'assets/nationalID_icon.png',
                                  title: "National ID",
                                  status: "Completed",
                                  statusColor: const Color(0xFF4CAF50),
                                  showProgress: false,
                                  iconBg: const Color(0xFFDCEDC8),
                                  onTap: () {
                                    print("Navigating to National ID Panel");
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Image.asset(iconPath, width: 24, height: 24, fit: BoxFit.contain),
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
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      size: 28,
                    ),
                    if (showProgress)
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
