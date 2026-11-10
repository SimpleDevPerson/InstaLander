import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system('Sistema (Automatico)'),
  samsung('Samsung One UI'),
  light('Chiaro'),
  dark('Scuro');

  const AppThemeMode(this.label);
  final String label;

  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.samsung:
        return ThemeMode.system; // Samsung theme follows system light/dark
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _appThemeMode = AppThemeMode.system;
  static const String _themeKey = 'app_theme_mode';

  AppThemeMode get appThemeMode => _appThemeMode;
  ThemeMode get themeMode => _appThemeMode.toThemeMode();
  bool get isSamsungTheme => _appThemeMode == AppThemeMode.samsung;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _appThemeMode = AppThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setAppThemeMode(AppThemeMode mode) async {
    _appThemeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
}