import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final PageController _imageController = PageController();
  final PageController _devController = PageController();
  int _imagePage = 0;
  int _devPage = 0;

  final List<Map<String, String>> _developers = [
    {'name': 'Jobel R. Araw', 'role': 'Project Manager', 'image': 'assets/jobel.png'},
    {'name': 'Jester Von G. Resma', 'role': 'Developer', 'image': 'assets/von.png'},
    {'name': 'Meagan S. Enguerra', 'role': 'UI/UX Designer', 'image': 'assets/meagan.png'},
  ];

  @override
  void dispose() {
    _imageController.dispose();
    _devController.dispose();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Image Slider ──
                  SizedBox(
                    height: 260,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      child: PageView.builder(
                        controller: _imageController,
                        itemCount: 4, // Updated to match the length of images list
                        onPageChanged: (i) => setState(() => _imagePage = i),
                        itemBuilder: (context, index) {
                          final images = [
                            'assets/cityhall.jpg',
                            'assets/cityhall1.jpg',
                            'assets/cityhall2.jpg',
                            'assets/cityhall3.jpg',
                          ];
                          return Opacity(
                            opacity: 0.60,
                            child: Image.asset(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Image dots ──
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
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
                  const SizedBox(height: 10),

                  // ── Description ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(
                            text: 'DocsEase',
                            style: TextStyle(
                              color: Color(0xFF2B6FD4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                            ' is a mobile assistant designed to help citizens navigate government services more easily in Binan City Hall. It provides clear information, guided steps, and smart navigation to simplify document processing in government offices.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── The Visionaries Card ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2D8E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'The Visionaries',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Meet the team behind the platform',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 240,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PageView.builder(
                                controller: _devController,
                                itemCount: _developers.length,
                                onPageChanged: (i) =>
                                    setState(() => _devPage = i),
                                itemBuilder: (context, index) {
                                  final dev = _developers[index];
                                  return Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.12),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            dev['image']!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  color:
                                                  const Color(0xFFB0C8D8),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 90,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        dev['name']!,
                                        style: const TextStyle(
                                          color: Color(0xFF2B6FD4),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dev['role']!,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              Positioned(
                                left: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    if (_devPage > 0) {
                                      _devController.previousPage(
                                        duration: const Duration(
                                            milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.chevron_left,
                                    size: 36,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),

                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    if (_devPage <
                                        _developers.length - 1) {
                                      _devController.nextPage(
                                        duration: const Duration(
                                            milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.chevron_right,
                                    size: 36,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                          List.generate(_developers.length, (i) {
                            return AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              width: _devPage == i ? 10 : 8,
                              height: _devPage == i ? 10 : 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _devPage == i
                                    ? const Color(0xFF2B6FD4)
                                    : Colors.grey.shade400,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // ── Contact Us ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2D8E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ContactTile(imagePath: 'assets/phone_icon.png', label: '0983 124 1247'),
                        _ContactTile(imagePath: 'assets/at_icon.png', label: 'docsease@gmail.com'),
                        _ContactTile(imagePath: 'assets/fb_icon.png', label: 'facebook.com/docsease'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Tile ──────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final String imagePath;
  final String label;

  const _ContactTile({required this.imagePath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFD6E8F5),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.contact_page,
                size: 20,
                color: Color(0xFF2B6FD4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}