import 'package:flutter/material.dart';

import 'theme_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._(this._preferences, this._themeMode);

  static Future<ThemeController> create({ThemePreferences? preferences}) async {
    final prefs = preferences ?? const ThemePreferences();
    final savedMode = await prefs.loadThemeMode();
    return ThemeController._(prefs, savedMode);
  }

  final ThemePreferences _preferences;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _preferences.saveThemeMode(mode);
  }

  Future<void> toggleDarkMode(bool enabled) =>
      setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
}
