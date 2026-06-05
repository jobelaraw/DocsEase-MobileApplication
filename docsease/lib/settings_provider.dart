import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ChangeNotifier gives this class the power to "notifyListeners()"
class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'English';
  double _fontSize = 0.5;

  bool _savedIsDarkMode = false;
  String _savedLanguage = 'English';
  double _savedFontSize = 0.5;
  
  bool _hasUnsavedPreview = false;

  // Getters so the rest of the app can read the current settings
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  double get fontSize => _fontSize;
  bool get hasUnsavedPreview => _hasUnsavedPreview;

  // expose saved vs pending for modal display
  bool get savedDarkMode => _savedIsDarkMode;
  String get savedLanguage => _savedLanguage;
  double get savedFontSize => _savedFontSize;
  bool get pendingDarkMode => _isDarkMode;
  String get pendingLanguage => _language;
  double get pendingFontSize => _fontSize;

  // Load settings when the app starts or when a user logs in
  Future<void> loadSettings() async {
    User? user = FirebaseAuth.instance.currentUser;
    String boxName = user != null ? 'settings_${user.uid}' : 'settings_guest';

    Box box = await Hive.openBox(boxName);

    _isDarkMode = box.get('isDarkMode', defaultValue: false);
    _savedIsDarkMode = _isDarkMode;
    _language = box.get('language', defaultValue: 'English');
    _savedLanguage = _language;
    _fontSize = box.get('fontSize', defaultValue: 0.5);
    _savedFontSize = _fontSize;

    // broadcast the loaded settings to the whole app
    notifyListeners();
  }

  void previewSettings({required bool isDark, required String language, required double fontSize}) {
    _isDarkMode = isDark;
    _language = language;
    _fontSize = fontSize;
    _hasUnsavedPreview =
        _isDarkMode != _savedIsDarkMode ||
        _language != _savedLanguage ||
        (_fontSize - _savedFontSize).abs() > 0.001;
    notifyListeners();
  }

  // Called when the switch is toggled — instant preview and not saved yet
  void previewDarkMode(bool isDark) {
    previewSettings(isDark: isDark, language: _language, fontSize: _fontSize);
  }

  // Revert dark mode to last saved value (this is called when leaving Settings without saving)
  void revertDarkModePreview() {
    _isDarkMode = _savedIsDarkMode;
    _language = _savedLanguage;
    _fontSize = _savedFontSize;
    _hasUnsavedPreview = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
}

  // Save settings and instantly update the UI
  Future<void> saveSettings(bool isDark, String lang, double size) async {
    User? user = FirebaseAuth.instance.currentUser;
    String boxName = user != null ? 'settings_${user.uid}' : 'settings_guest';

    Box box = await Hive.openBox(boxName);

    await box.put('isDarkMode', isDark);
    await box.put('language', lang);
    await box.put('fontSize', size);

    _isDarkMode = isDark;
    _savedIsDarkMode = isDark;
    _language = lang;
    _savedLanguage = lang;
    _fontSize = size;
    _savedFontSize = size;
    _hasUnsavedPreview = false;

    // broadcast the new settings to instantly change the screens
    notifyListeners();
  }
}
