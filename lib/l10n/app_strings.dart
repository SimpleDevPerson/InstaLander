import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'app_localizations.dart';

/// Locale access for services and legacy model labels. Widgets use context.l10n.
class AppStrings {
  static Locale resolveLocale(
    List<Locale>? locales,
    Iterable<Locale> supported,
  ) {
    final resolved = basicLocaleListResolution(locales, supported);
    useLanguage(resolved.languageCode);
    Intl.defaultLocale = resolved.languageCode;
    return resolved;
  }

  static AppLocalizations current = lookupAppLocalizations(const Locale('it'));
  static void useLanguage(String code) {
    current = lookupAppLocalizations(Locale(code == 'it' ? 'it' : 'en'));
  }
}

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppStrings.current;
}
