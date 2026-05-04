import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final PageController _imageController = PageController();
  int _imagePage = 0;
  Timer? _autoSlideTimer;

  final List<Map<String, String>> _developers = [
    {'name': 'Jobel R. Araw', 'role': 'Project Manager', 'image': 'assets/jobel.png', 'roleIcon': 'assets/projectmanager_icon.png'},
    {'name': 'Jester Von G. Resma', 'role': 'Developer', 'image': 'assets/von.png', 'roleIcon': 'assets/developer_icon.png'},
    {'name': 'Meagan S. Enguerra', 'role': 'UI/UX Designer', 'image': 'assets/meagan.png', 'roleIcon': 'assets/designer_icon.png'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final nextPage = (_imagePage + 1) % 3;
      _imageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E8F5),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Slider Section
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.40),
                          blurRadius: 20,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        height: 260,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _imageController,
                              itemCount: 3,
                              onPageChanged: (i) {
                                setState(() => _imagePage = i);
                                _startAutoSlide();
                              },
                              itemBuilder: (context, index) {
                                final images = [
                                  'assets/cityhall.jpg',
                                  'assets/cityhall1.jpg',
                                  'assets/cityhall2.jpg',
                                ];
                                return Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF7A9BB5),
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.45),
                                    Colors.black.withOpacity(0.80),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DocsEase',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF93C5FD),
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'A mobile assistant designed to help citizens navigate government services more easily in Binan City Hall. It provides clear information, guided steps, and smart navigation to simplify document processing in government offices.',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16.5,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _imagePage == i ? 10 : 8,
                        height: _imagePage == i ? 10 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _imagePage == i
                              ? const Color(0xFF2B6FD4)
                              : Colors.grey.shade400,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('15k +', 'Active Users', const Color(0xFF2B6FD4), Colors.white, Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('4.9', 'App Store Rating', const Color(0xFFADD0EC), Colors.black87, Colors.black54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 45),

                  // Team Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'The Team',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFADD0EC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Creators',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Developers List
                  Column(
                    children: _developers.map((dev) => _buildDevTile(dev)).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Contact Section
                  Text(
                    'Connect With Us',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 14),


                  _ContactTile(
                    iconAsset: 'assets/email_icon.png',
                    fallbackIcon: Icons.mail_outline,
                    label: 'docsease@gmail.com',
                    fontSize: 16,
                  ),
                  const SizedBox(height: 10),


                  _ContactTile(
                    iconAsset: 'assets/contact_icon.png',
                    fallbackIcon: Icons.phone_outlined,
                    label: '0983 124 1247',
                    fontSize: 16,
                  ),

                  const SizedBox(height: 24),

                  // Social Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialCircle(iconAsset: 'assets/fb_icon.png', fallbackIcon: Icons.facebook),
                      const SizedBox(width: 12),
                      _SocialCircle(iconAsset: 'assets/share_icon.png', fallbackIcon: Icons.share_outlined),
                      const SizedBox(width: 12),
                      _SocialCircle(iconAsset: 'assets/connect_icon.png', fallbackIcon: Icons.chat_bubble_outline),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String val, String label, Color bg, Color textCol, Color subCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: GoogleFonts.inter(color: textCol, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(color: subCol, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildDevTile(Map<String, String> dev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCDD8E3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circle avatar
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD0DDE8),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                dev['image']!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dev['name']!,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dev['role']!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Role icon
          Image.asset(
            dev['roleIcon']!,
            width: 26,
            height: 26,
            color: const Color(0xFF2B6FD4),
            errorBuilder: (_, __, ___) => const Icon(
              Icons.work_outline,
              size: 24,
              color: Color(0xFF2B6FD4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Tile ───
class _ContactTile extends StatelessWidget {
  final String iconAsset;
  final IconData fallbackIcon;
  final String label;
  final double fontSize;

  const _ContactTile({
    required this.iconAsset,
    required this.fallbackIcon,
    required this.label,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCDD8E3), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFDEEAF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                iconAsset,
                color: const Color(0xFF2B6FD4),
                errorBuilder: (_, __, ___) => Icon(fallbackIcon, size: 22, color: const Color(0xFF2B6FD4)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              color: const Color(0xFF2B6FD4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Social Circle ───
class _SocialCircle extends StatelessWidget {
  final String iconAsset;
  final IconData fallbackIcon;

  const _SocialCircle({required this.iconAsset, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF0F4F8),
        border: Border.all(color: const Color(0xFFCDD8E3), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          iconAsset,
          color: const Color(0xFF2B6FD4),
          errorBuilder: (_, __, ___) => Icon(fallbackIcon, size: 22, color: const Color(0xFF2B6FD4)),
        ),
      ),
    );
  }
}