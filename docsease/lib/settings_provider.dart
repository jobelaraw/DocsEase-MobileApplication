import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ChangeNotifier gives this class the power to "notifyListeners()"
class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'English';
  double _fontSize = 0.5;

  // Getters so the rest of the app can read the current settings
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  double get fontSize => _fontSize;

  // Load settings when the app starts or when a user logs in
  Future<void> loadSettings() async {
    User? user = FirebaseAuth.instance.currentUser;
    String boxName = user != null ? 'settings_${user.uid}' : 'settings_guest';

    Box box = await Hive.openBox(boxName);

    _isDarkMode = box.get('isDarkMode', defaultValue: false);
    _language = box.get('language', defaultValue: 'English');
    _fontSize = box.get('fontSize', defaultValue: 0.5);

    // Broadcast the loaded settings to the whole app!
    notifyListeners();
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
    _language = lang;
    _fontSize = size;

    // Broadcast the new settings to instantly redraw the screens!
    notifyListeners();
  }
}
