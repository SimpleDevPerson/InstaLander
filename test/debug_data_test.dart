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
    await tester.scrollUntilVisible(find.text('Debug'), 250);
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
    app.dispose();
  });
}
