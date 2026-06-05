import 'package:docsease/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:docsease/app_modals.dart';
import 'package:docsease/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  double _fontSize = 0.5;

  final List<String> _languages = ['English', 'Filipino'];

  late Box _settingsBox;
  bool _isLoadingBox = true;

  bool _savedBeforeLeaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  @override
  void dispose() {
    // If user navigated away WITHOUT saving, revert the dark mode preview
    if (!_savedBeforeLeaving) {
      Provider.of<SettingsProvider>(context, listen: false).revertDarkModePreview();
    }
    super.dispose();
  }

  Future<void> _loadUserSettings() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // If logged in, use their UID. If guest, use a generic 'guest' box.
    String boxName = currentUser != null ? 'settings_${currentUser.uid}' : 'settings_guest';

    _settingsBox = await Hive.openBox(boxName);

    if (mounted) {
      setState(() {
        // Fetch saved data, or provide default values if it's their first time
        _isDarkMode = _settingsBox.get('isDarkMode', defaultValue: false);
        _selectedLanguage = _settingsBox.get('language', defaultValue: 'English');
        _fontSize = _settingsBox.get('fontSize', defaultValue: 0.5);

        _isLoadingBox = false; // Data is loaded, reveal the screen!
      });
    }
    print(
      '======================\n'
      'Dark Mode: ${_isDarkMode}\n'
      'Language: ${_selectedLanguage}\n'
      'Font Size: ${_fontSize}\n'
      '=======================',
    );
  }

void _saveChanges() async {
  await ConfirmChangesModal.show(
    context,
    onPrimary: () {
      Navigator.of(context).pop(); // close confirm modal
      ChangesSavedModal.show(
        context,
        onPrimary: () {
          Navigator.of(context).pop(); 
          _savedBeforeLeaving = true;
        Provider.of<SettingsProvider>(context, listen: false)
              .saveSettings(_isDarkMode, _selectedLanguage, _fontSize);
        },
      );
    },
    onSecondary: () {
      Navigator.of(context).pop(); 
    },
  );

    print(
      '======================\n'
      'Dark Mode: ${_isDarkMode}\n'
      'Language: ${_selectedLanguage}\n'
      'Font Size: ${_fontSize}\n'
      '=======================',
    );
  }

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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onPrimary
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ..._languages.map(
                (lang) => ListTile(
                  title: Text(lang, style: GoogleFonts.inter(fontSize: 15)),
                  trailing: _selectedLanguage == lang
                      ? const Icon(Icons.check, color: Color.fromRGBO(32, 87, 206, 1.0))
                      : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoadingBox
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                            color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.15)),
                          ),
                          child: Column(
                            children: [
                              // Dark Mode row
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.dark_mode_outlined,
                                      size: 22,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Colors.black87,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Dark Mode',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: _isDarkMode,
                                      onChanged: (val) {
                                        setState(() => _isDarkMode = val);
                                        // Instantly previews the theme change app-wide
                                        Provider.of<SettingsProvider>(context, listen: false).previewDarkMode(val);
                                      },
                                      activeColor: const Color.fromRGBO(32, 87, 206, 1.0),
                                      activeTrackColor: const Color.fromRGBO(32, 87, 206, 0.3),
                                    ),
                                  ],
                                ),
                              ),

                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey.withOpacity(0.12),
                                indent: 16,
                                endIndent: 16,
                              ),

                              // Language
                              InkWell(
                                onTap: _showLanguagePicker,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.translate_outlined,
                                        size: 22,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Colors.black87,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Language',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$_selectedLanguage  ›',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface,
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
                            color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
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
                                  color: Theme.of(context).colorScheme.onSurface,
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
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Colors.black87,
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: const Color.fromRGBO(32, 87, 206, 1.0),
                                        inactiveTrackColor: Colors.grey.shade300,
                                        thumbColor: const Color.fromRGBO(32, 87, 206, 1.0),
                                        overlayColor: const Color.fromRGBO(32, 87, 206, 0.15),
                                        trackHeight: 3.0,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 10,
                                        ),
                                      ),
                                      child: Slider(
                                        value: _fontSize,
                                        min: 0.0,
                                        max: 1.0,
                                        onChanged: (val) => setState(() => _fontSize = val),
                                      ),
                                    ),
                                  ),
                                  // Large A
                                  Text(
                                    'A',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        //Save Changes Button
                        CustomButton(
                          buttonText: 'Save Changes',
                          btnElevation: 4,
                          btnRadius: 15,
                          onTapAction: _saveChanges,
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
        color: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onPrimary
        : Colors.black87,
        letterSpacing: 1.0,
      ),
    );
  }
}
