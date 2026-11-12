import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppIconStyle {
  original('Originale'),
  dark('Scura');

  const AppIconStyle(this.label);
  final String label;
}

enum AppThemeStyle {
  samsungOneUi('Samsung One UI'),
  materialExpressive('Material Design Expressive');

  const AppThemeStyle(this.label);
  final String label;
}

enum AppBrightnessMode {
  system('Predefinito di sistema', Icons.brightness_auto_outlined),
  light('Chiaro', Icons.light_mode_outlined),
  dark('Scuro', Icons.dark_mode_outlined);

  const AppBrightnessMode(this.label, this.icon);
  final String label;
  final IconData icon;

  ThemeMode get themeMode => switch (this) {
        AppBrightnessMode.system => ThemeMode.system,
        AppBrightnessMode.light => ThemeMode.light,
        AppBrightnessMode.dark => ThemeMode.dark,
      };
}

class ThemeProvider extends ChangeNotifier {
  AppThemeStyle _themeStyle = AppThemeStyle.samsungOneUi;
  AppBrightnessMode _brightnessMode = AppBrightnessMode.system;
  AppIconStyle _appIconStyle = AppIconStyle.original;
  static const MethodChannel _appIconChannel =
      MethodChannel('com.simpledevperson.instalander/app_icon');
  static const String _themeStyleKey = 'app_theme_style';
  static const String _brightnessModeKey = 'app_brightness_mode';
  static const String _appIconStyleKey = 'app_icon_style';
  static const String _legacyThemeKey = 'app_theme_mode';

  AppThemeStyle get themeStyle => _themeStyle;
  AppBrightnessMode get brightnessMode => _brightnessMode;
  AppIconStyle get appIconStyle => _appIconStyle;
  ThemeMode get themeMode => _brightnessMode.themeMode;
  bool get isSamsungTheme => _themeStyle == AppThemeStyle.samsungOneUi;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final styleIndex = prefs.getInt(_themeStyleKey);
    final brightnessIndex = prefs.getInt(_brightnessModeKey);
    final iconIndex = prefs.getInt(_appIconStyleKey);
    if (styleIndex != null || brightnessIndex != null) {
      if (styleIndex != null &&
          styleIndex >= 0 &&
          styleIndex < AppThemeStyle.values.length) {
        _themeStyle = AppThemeStyle.values[styleIndex];
      }
      if (brightnessIndex != null &&
          brightnessIndex >= 0 &&
          brightnessIndex < AppBrightnessMode.values.length) {
        _brightnessMode = AppBrightnessMode.values[brightnessIndex];
      }
    } else {
      final legacyMode = prefs.getInt(_legacyThemeKey);
      switch (legacyMode) {
        case 0:
          _themeStyle = AppThemeStyle.samsungOneUi;
          break;
        case 1:
          _themeStyle = AppThemeStyle.samsungOneUi;
          break;
        case 2:
          _brightnessMode = AppBrightnessMode.light;
          break;
        case 3:
          _brightnessMode = AppBrightnessMode.dark;
          break;
      }
      await prefs.setInt(_themeStyleKey, _themeStyle.index);
      await prefs.setInt(_brightnessModeKey, _brightnessMode.index);
    }

    if (iconIndex != null &&
        iconIndex >= 0 &&
        iconIndex < AppIconStyle.values.length) {
      _appIconStyle = AppIconStyle.values[iconIndex];
    }

    notifyListeners();
  }

  Future<void> setAppIconStyle(AppIconStyle style) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _appIconChannel.invokeMethod<void>(
        'setAppIcon',
        style == AppIconStyle.dark ? 'dark' : 'original',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_appIconStyleKey, style.index);
    _appIconStyle = style;
    notifyListeners();
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    _themeStyle = style;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeStyleKey, style.index);
  }

  Future<void> setBrightnessMode(AppBrightnessMode mode) async {
    _brightnessMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_brightnessModeKey, mode.index);
  }

  Future<void> resetToDefaults() async {
    await setAppIconStyle(AppIconStyle.original);
    _themeStyle = AppThemeStyle.samsungOneUi;
    _brightnessMode = AppBrightnessMode.system;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeStyleKey, _themeStyle.index);
    await prefs.setInt(_brightnessModeKey, _brightnessMode.index);
    await prefs.remove(_legacyThemeKey);
  }
}
