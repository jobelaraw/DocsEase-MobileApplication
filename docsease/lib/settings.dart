import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  double _fontSize = 0.5; 

  final List<String> _languages = [
    'English',
    'Filipino',
  ];

void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Language',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ..._languages.map((lang) => ListTile(
                    title: Text(
                      lang,
                      style: GoogleFonts.inter(fontSize: 15),
                    ),
                    trailing: _selectedLanguage == lang
                        ? const Icon(Icons.check,
                            color: Color.fromRGBO(32, 87, 206, 1.0))
                        : null,
                    onTap: () {
                      setState(() => _selectedLanguage = lang);
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved!',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(32, 87, 206, 1.0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(235, 243, 255, 1.0),

      // ── Floating back button ──
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(1),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: const SizedBox(
              width: 60,
              height: 60,
              child: Icon(Icons.arrow_back, size: 30, color: Colors.black),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      body: Column(
        children: [
          Container(
            color: const Color.fromRGBO(32, 87, 206, 1.0),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Center(
                  child: Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //APPEARANCE Section
                  _sectionLabel('APPEARANCE'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        // Dark Mode row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.dark_mode_outlined,
                                  size: 22, color: Colors.black87),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Dark Mode',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _isDarkMode,
                                onChanged: (val) =>
                                    setState(() => _isDarkMode = val),
                                activeColor:
                                    const Color.fromRGBO(32, 87, 206, 1.0),
                                activeTrackColor: const Color.fromRGBO(
                                    32, 87, 206, 0.3),
                              ),
                            ],
                          ),
                        ),

                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.withOpacity(0.12),
                            indent: 16,
                            endIndent: 16),

                        // Language 
                        InkWell(
                          onTap: _showLanguagePicker,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.translate_outlined,
                                    size: 22, color: Colors.black87),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Language',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$_selectedLanguage  ›',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  //ACCESSIBILITY Section
                  _sectionLabel('ACCESSIBILITY'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Font Size',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Small A
                            Text(
                              'A',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor:const Color.fromRGBO(32, 87, 206, 1.0),
                                  inactiveTrackColor:Colors.grey.shade300,
                                  thumbColor:const Color.fromRGBO(32, 87, 206, 1.0),
                                  overlayColor: const Color.fromRGBO(32, 87, 206, 0.15),
                                  trackHeight: 3.0,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 10),
                                ),
                                child: Slider(
                                  value: _fontSize,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (val) =>
                                      setState(() => _fontSize = val),
                                ),
                              ),
                            ),
                            // Large A
                            Text(
                              'A',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  //Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(32, 87, 206, 1.0),
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 1.0,
      ),
    );
  }
}