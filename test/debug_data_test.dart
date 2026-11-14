import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/settings_screen.dart';
import 'package:instalander/services/debug_data_service.dart';
import 'package:instalander/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'debug fixtures have valid dated intervals and both reciprocal and nonreciprocal profiles',
    () {
      final data = DebugDataService(
        random: Random(7),
        now: DateTime(2026, 11, 13),
      );
      final (followers, following) = data.report();
      expect(followers, isNotEmpty);
      expect(following.length, greaterThan(followers.length));
      expect(followers.keys.every(following.containsKey), isTrue);
      final timeline = data.timeline();
      expect(timeline, hasLength(4));
      for (final interval in timeline) {
        expect(interval.previous.date.isBefore(interval.current.date), isTrue);
        expect(interval.users, isNotEmpty);
        expect(
          interval.users.every(
            (u) =>
                u.username.startsWith('debug_') &&
                !interval.current.followers.containsKey(u.username),
          ),
          isTrue,
        );
      }
    },
  );

  test(
    'debug sections work independently and interactions never save fake profiles',
    () async {
      final app = AppProvider();
      app.populateDebugTimeline();
      expect(app.timeline, hasLength(4));
      expect(app.following, isEmpty);
      expect(app.whitelist, isEmpty);
      app.populateDebugWhitelist();
      expect(app.whitelist, hasLength(15));
      expect(app.following, isEmpty);
      app.populateDebugReport();
      expect(app.hasData, isTrue);
      expect(app.hasFollowersFile, isTrue);
      expect(app.hasFollowingFile, isTrue);
      expect(app.hasPartialData, isFalse);
      expect(app.nonFollowers, isNotEmpty);
      expect(app.stats['whitelist'], 15);
      final name = app.nonFollowers.first.username;
      final count = app.nonFollowers.length;
      app.addToWhitelist(name);
      expect(app.nonFollowers, hasLength(count - 1));
      expect(app.isInWhitelist(name), isTrue);
      await app.markProfileViewed(name);
      expect(app.isProfileViewed(name), isTrue);
      app.removeFromWhitelist(name);
      expect(app.nonFollowers, hasLength(count));
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
      // A fresh session must not inherit any of the fake profiles.
      final fresh = AppProvider();
      expect(fresh.timeline, isEmpty);
      expect(fresh.whitelist, isEmpty);
      expect(fresh.following, isEmpty);
      fresh.dispose();
      app.dispose();
    },
  );

  testWidgets('rapid version taps update one banner with the exact countdown', (
    tester,
  ) async {
    final app = AppProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: app),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Versione'), 250);
    await tester.pumpAndSettle();
    State? bannerState;
    for (var tap = 1; tap <= 9; tap++) {
      await tester.tap(find.text('Versione'));
      await tester.pump(const Duration(milliseconds: 40));
      expect(app.debugToolsEnabled, isFalse);
      if (tap < 5) {
        expect(find.byType(SnackBar), findsNothing);
      } else {
        expect(find.byType(SnackBar), findsOneWidget);
        bannerState ??= tester.state(find.byType(SnackBar));
        expect(tester.state(find.byType(SnackBar)), same(bannerState));
        final remaining = 10 - tap;
        expect(
          find.text(
            remaining == 1
                ? 'Ancora un tocco per attivare la modalità sviluppatore'
                : 'Ancora $remaining tocchi per attivare la modalità sviluppatore',
          ),
          findsOneWidget,
        );
      }
    }
    await tester.tap(find.text('Versione'));
    await tester.pumpAndSettle();
    expect(app.debugToolsEnabled, isTrue);
    expect(find.text('Modalità sviluppatore attivata'), findsOneWidget);
    expect(tester.state(find.byType(SnackBar)), same(bannerState));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    app.dispose();
  });

  testWidgets('debug options can be hidden and unlocked again', (tester) async {
    final app = AppProvider();
    await app.enableDebugTools();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: app),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Nascondi opzioni di debug').hitTestable(),
      250,
    );
    await tester.tap(find.text('Nascondi opzioni di debug'));
    await tester.pumpAndSettle();
    expect(app.debugToolsEnabled, isFalse);
    expect(find.text('Modalità di compilazione'), findsNothing);
    expect(
      (await SharedPreferences.getInstance()).getBool('debug_tools_enabled'),
      isFalse,
    );
    await tester.scrollUntilVisible(find.text('Versione').hitTestable(), -200);
    for (var tap = 0; tap < 9; tap++) {
      await tester.tap(find.text('Versione'));
      await tester.pump();
    }
    expect(app.debugToolsEnabled, isFalse);
    await tester.tap(find.text('Versione'));
    await tester.pumpAndSettle();
    expect(app.debugToolsEnabled, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    app.dispose();
  });

  testWidgets('debug buttons populate their sections and reset remains last', (
    tester,
  ) async {
    final app = AppProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: app),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.samsungDarkTheme,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Versione'), 250);
    await tester.pumpAndSettle();
    for (var tap = 0; tap < 9; tap++) {
      await tester.tap(find.text('Versione'));
      await tester.pump();
    }
    expect(app.debugToolsEnabled, isFalse);
    expect(find.text('Debug'), findsNothing);
    expect(find.text('Popola report'), findsNothing);
    expect(find.text('Cancella tutti i dati'), findsNothing);

    await tester.tap(find.text('Versione'));
    await tester.pumpAndSettle();
    expect(app.debugToolsEnabled, isTrue);
    expect(find.text('Modalità sviluppatore attivata'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool('debug_tools_enabled'),
      isTrue,
    );
    await tester.scrollUntilVisible(find.text('Modalità di compilazione'), 250);
    await tester.pumpAndSettle();
    for (final label in [
      'Popola timeline',
      'Popola whitelist',
      'Popola report',
    ]) {
      await tester.ensureVisible(find.text(label));
      final actionCard = find.ancestor(
        of: find.text(label),
        matching: find.byType(Card),
      );
      expect(actionCard, findsOneWidget);
      expect(
        find.descendant(
          of: actionCard,
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsNothing,
      );
      final cardRect = tester.getRect(actionCard);
      final listRect = tester.getRect(find.byType(ListView));
      expect(cardRect.left, listRect.left + 16);
      expect(cardRect.right, listRect.right - 16);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(app.timeline, isNotEmpty);
    expect(app.whitelist, isNotEmpty);
    expect(app.nonFollowers, isNotEmpty);
    final reset = find.text('Cancella tutti i dati');
    await tester.ensureVisible(reset);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(reset).dy,
      greaterThan(tester.getTopLeft(find.text('Popola report')).dy),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    // Recreating the settings page must retain the unlocked tools.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: app),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Modalità di compilazione'), 250);
    expect(find.text('Modalità di compilazione'), findsOneWidget);
    expect(find.text('Debug'), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox.shrink());
    app.dispose();
  });
}
