import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/l10n/app_localizations.dart';
import 'package:instalander/l10n/app_strings.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/settings_screen.dart';
import 'package:instalander/widgets/language_selector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app(ThemeProvider theme) => MultiProvider(
  providers: [
    ChangeNotifierProvider<ThemeProvider>.value(value: theme),
    ChangeNotifierProvider(create: (_) => AppProvider()),
  ],
  child: Consumer<ThemeProvider>(
    builder: (context, value, _) => MaterialApp(
      locale: value.locale,
      supportedLocales: const [Locale('en'), Locale('it')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeListResolutionCallback: AppStrings.resolveLocale,
      home: const SettingsScreen(),
    ),
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('English covers every Italian message and preserves placeholders', () {
    Map<String, dynamic> catalog(String code) =>
        jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
            as Map<String, dynamic>;
    final italian = catalog('it');
    final english = catalog('en');
    final keys = italian.keys.where((key) => !key.startsWith('@')).toSet();
    expect(english.keys.where((key) => !key.startsWith('@')).toSet(), keys);
    for (final key in keys) {
      expect(english[key], isNotEmpty, reason: key);
      Set<String?> placeholders(String text) => RegExp(
        r'\{(arg\d+)\}',
      ).allMatches(text).map((m) => m.group(1)).toSet();
      expect(
        placeholders(english[key] as String),
        placeholders(italian[key] as String),
        reason: key,
      );
    }
  });

  for (final code in ['it', 'en', 'fr']) {
    testWidgets('system language $code resolves correctly', (tester) async {
      tester.platformDispatcher.localeTestValue = Locale(code);
      tester.platformDispatcher.localesTestValue = [Locale(code)];
      final theme = ThemeProvider();
      await tester.pumpWidget(app(theme));
      await tester.pumpAndSettle();
      expect(
        find.text(code == 'it' ? 'Impostazioni' : 'Settings'),
        findsOneWidget,
      );
      expect(theme.languageCode, isNull);
      expect(AppStrings.current.localeName, code == 'it' ? 'it' : 'en');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      theme.dispose();
    });
  }

  testWidgets('language switch updates UI immediately and survives a restart', (
    tester,
  ) async {
    final theme = ThemeProvider();
    await tester.pumpWidget(app(theme));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(LanguageSelector), 150);
    await tester.tap(find.byKey(const ValueKey('language-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsWidgets);
    expect(
      (await SharedPreferences.getInstance()).getString('app_language'),
      'en',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    theme.dispose();

    final restored = ThemeProvider();
    await tester.pumpWidget(app(restored));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(restored.languageCode, 'en');
    await tester.scrollUntilVisible(find.byType(LanguageSelector), 150);
    await tester.tap(find.byKey(const ValueKey('language-en')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System (automatic)').last);
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getString('app_language'),
      isNull,
    );
    tester.platformDispatcher.localeTestValue = const Locale('en');
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    restored.dispose();
  });
}
