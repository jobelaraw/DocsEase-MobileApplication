import 'package:docsease/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:docsease/app_modals.dart';
import 'package:docsease/custom_button.dart';
import 'package:docsease/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _languages = ['English', 'Filipino'];

  bool _isLoading = true;
  bool isChangesLoading = false;
  bool _savedBeforeLeaving = false;

  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    // 1. Safely cache the provider right when the screen initializes
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    // Brief delay to ensure provider is fully loaded from side_bar
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    if (!_savedBeforeLeaving) {
      // 2. Safely revert changes using the cached provider
      _settingsProvider.revertDarkModePreview();
    }
    super.dispose();
  }

  void _saveChanges() async {
    FocusManager.instance.primaryFocus?.unfocus();

    // if (_settingsProvider.pendingDarkMode == _settingsProvider.savedDarkMode &&
    //     _settingsProvider.pendingLanguage == _settingsProvider.savedLanguage &&
    //     (_settingsProvider.pendingFontSize - _settingsProvider.savedFontSize).abs() < 0.001) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         AppLocalizations.translate('No changes made.', _settingsProvider.pendingLanguage),
    //       ),
    //     ),
    //   );
    //   return;
    // }

    await ConfirmChangesModal.show(
      context,
      onPrimary: () async {
        Navigator.of(context, rootNavigator: true).pop();

        setState(() {
          isChangesLoading = true;
        });

        await Future.delayed(const Duration(milliseconds: 1000));

        try {
          await _settingsProvider.saveSettings(
            _settingsProvider.pendingDarkMode,
            _settingsProvider.pendingLanguage,
            _settingsProvider.pendingFontSize,
          );

          if (mounted) {
            setState(() {
              _savedBeforeLeaving = true;
            });

            // Show success modal and wait for it to close
            await ChangesSavedModal.show(
              context,
              onPrimary: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            );
            if (mounted) {
              setState(() {
                isChangesLoading = false;
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isChangesLoading = false;
            });
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       "${AppLocalizations.translate('Failed to save settings:', _settingsProvider.pendingLanguage)} $e",
            //     ),
            //   ),
            // );
          }
        }
      },
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
                AppLocalizations.translate('Select Language', _settingsProvider.pendingLanguage),
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
                  trailing: _settingsProvider.pendingLanguage == lang
                      ? const Icon(Icons.check, color: Color.fromRGBO(32, 87, 206, 1.0))
                      : null,
                  onTap: () {
                    _settingsProvider.previewSettings(
                      isDark: _settingsProvider.pendingDarkMode,
                      language: lang,
                      fontSize: _settingsProvider.pendingFontSize,
                    );
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
    // Listen to the provider to instantly rebuild UI on revert/save
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // APPEARANCE Section
                        _sectionLabel(
                          AppLocalizations.translate(
                            'APPEARANCE',
                            settingsProvider.pendingLanguage,
                          ),
                        ),
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
                                        AppLocalizations.translate(
                                          'Dark Mode',
                                          settingsProvider.pendingLanguage,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: settingsProvider.pendingDarkMode,
                                      onChanged: (val) {
                                        settingsProvider.previewDarkMode(val);
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
                                          AppLocalizations.translate(
                                            'Language',
                                            settingsProvider.pendingLanguage,
                                          ),
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${settingsProvider.pendingLanguage}  ›',
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

                        // ACCESSIBILITY Section
                        _sectionLabel(
                          AppLocalizations.translate(
                            'ACCESSIBILITY',
                            settingsProvider.pendingLanguage,
                          ),
                        ),
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
                                AppLocalizations.translate(
                                  'Font Size',
                                  settingsProvider.pendingLanguage,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
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
                                        value: settingsProvider.pendingFontSize,
                                        min: 0.0,
                                        max: 1.0,
                                        onChanged: (val) {
                                          settingsProvider.previewSettings(
                                            isDark: settingsProvider.pendingDarkMode,
                                            language: settingsProvider.pendingLanguage,
                                            fontSize: val,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
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

                        // Save Changes Button
                        CustomButton(
                          buttonText: AppLocalizations.translate(
                            'Save Changes',
                            settingsProvider.pendingLanguage,
                          ),
                          btnElevation: 4,
                          btnRadius: 15,
                          isLoading: isChangesLoading,
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
