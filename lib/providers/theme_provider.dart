import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

enum AppIconStyle {
  original,
  dark,
  white,
  glowDark;

  String get label => switch (this) {
    original => AppStrings.current.originalIcon,
    dark => AppStrings.current.darkIcon,
    white => AppStrings.current.whiteIcon,
    glowDark => AppStrings.current.glowDarkIcon,
  };
}

enum AppThemeStyle {
  samsungOneUi('Samsung One UI'),
  materialExpressive('Material Design Expressive');

  const AppThemeStyle(this.label);
  final String label;
}

enum AppBrightnessMode {
  system(Icons.brightness_auto_outlined),
  light(Icons.light_mode_outlined),
  dark(Icons.dark_mode_outlined);

  const AppBrightnessMode(this.icon);
  String get label => switch (this) {
    system => AppStrings.current.systemDefault,
    light => AppStrings.current.light,
    dark => AppStrings.current.dark,
  };
  final IconData icon;

  ThemeMode get themeMode => switch (this) {
    AppBrightnessMode.system => ThemeMode.system,
    AppBrightnessMode.light => ThemeMode.light,
    AppBrightnessMode.dark => ThemeMode.dark,
  };
}

class ThemeProvider extends ChangeNotifier {
  static const _languageKey = 'app_language';
  static const _localeChannel = MethodChannel(
    'com.simpledevperson.instalander/locale',
  );
  String? _languageCode;
  String? get languageCode => _languageCode;
  Locale? get locale => _languageCode == null ? null : Locale(_languageCode!);

  Future<void> setLanguage(String? code) async {
    if (code != null && !AppStrings.isSupportedLanguage(code)) {
      throw ArgumentError.value(code);
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = code == null
        ? await prefs.remove(_languageKey)
        : await prefs.setString(_languageKey, code);
    if (!saved) throw StateError(AppStrings.current.cannotSavePreference);
    _languageCode = code;
    _applyLanguage();
    notifyListeners();
    await _syncNativeLanguage();
  }

  void _applyLanguage() {
    AppStrings.useLanguage(
      _languageCode ??
          WidgetsBinding.instance.platformDispatcher.locale.languageCode,
    );
  }

  Future<void> _syncNativeLanguage() async {
    try {
      await _localeChannel.invokeMethod<void>('setLanguage', _languageCode);
    } on MissingPluginException {
      // Widget tests and non-Android targets have no native notifications.
    } on PlatformException {
      // Flutter language remains available if native resources are unavailable.
    }
  }

  AppThemeStyle _themeStyle = AppThemeStyle.samsungOneUi;
  AppBrightnessMode _brightnessMode = AppBrightnessMode.system;
  AppIconStyle _appIconStyle = AppIconStyle.white;
  static const MethodChannel _appIconChannel = MethodChannel(
    'com.simpledevperson.instalander/app_icon',
  );
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

    final language = prefs.getString(_languageKey);
    _languageCode = language != null && AppStrings.isSupportedLanguage(language)
        ? language
        : null;
    _applyLanguage();
    unawaited(_syncNativeLanguage());

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
      if (legacyMode != null) {
        await prefs.setInt(_themeStyleKey, _themeStyle.index);
        await prefs.setInt(_brightnessModeKey, _brightnessMode.index);
      }
    }

    if (iconIndex != null &&
        iconIndex >= 0 &&
        iconIndex < AppIconStyle.values.length) {
      _appIconStyle = AppIconStyle.values[iconIndex];
    }

    try {
      await _syncNativeIcon(_appIconStyle);
    } on MissingPluginException {
      // Widget tests and non-Android targets have no launcher aliases.
    } on PlatformException {
      // Keep the saved choice available if the launcher is temporarily unavailable.
    }
    notifyListeners();
  }

  Future<void> _syncNativeIcon(AppIconStyle style) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _appIconChannel.invokeMethod<void>('setAppIcon', style.name);
    }
  }

  Future<void> setAppIconStyle(AppIconStyle style) async {
    await _syncNativeIcon(style);

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
    await setLanguage(null);
    await setAppIconStyle(AppIconStyle.white);
    _themeStyle = AppThemeStyle.samsungOneUi;
    _brightnessMode = AppBrightnessMode.system;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeStyleKey, _themeStyle.index);
    await prefs.setInt(_brightnessModeKey, _brightnessMode.index);
    await prefs.remove(_legacyThemeKey);
  }
}
