import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/models/import_snapshot.dart';
import 'package:instalander/models/user.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/settings_screen.dart';
import 'package:instalander/screens/timeline_screen.dart';
import 'package:instalander/services/reminder_service.dart';
import 'package:instalander/theme/app_theme.dart';
import 'package:instalander/widgets/reminder_interval_selector.dart';
import 'package:instalander/widgets/settings_toggle_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

ImportSnapshot snapshot(int month, List<String> users) => ImportSnapshot(
  date: DateTime(2026, month, 1),
  followersImported: true,
  hasFollowers: true,
  hasFollowing: true,
  followers: {
    for (final name in users) name: InstagramUser(username: name, timestamp: 0),
  },
  following: {},
);

class TimelineProvider extends AppProvider {
  TimelineProvider(this.intervals);
  final List<UnfollowInterval> intervals;
  @override
  bool get isLoading => false;
  @override
  List<UnfollowInterval> get timeline => intervals;
  @override
  Set<String> get whitelist => {'lost'};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'reminder section offers all three frequencies without enabling notifications',
    (tester) async {
      const channel = MethodChannel(
        'com.simpledevperson.instalander/reminders',
      );
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
      final app = AppProvider();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppProvider>.value(value: app),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.samsungLightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Switch switchFor(String title) => tester.widget<Switch>(
        find.descendant(
          of: find.ancestor(
            of: find.text(title),
            matching: find.byType(SettingsToggleTile),
          ),
          matching: find.byType(Switch),
        ),
      );
      await tester.scrollUntilVisible(find.text('Promemoria'), 250);
      await tester.pumpAndSettle();
      expect(find.text('Promemoria'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('reminder-frequency')),
        250,
      );
      await tester.pumpAndSettle();
      final reminderCard = find.ancestor(
        of: find.text('Promemoria Instagram'),
        matching: find.byType(Card),
      );
      final cardRect = tester.getRect(reminderCard);
      final listRect = tester.getRect(find.byType(ListView));
      expect(cardRect.left, listRect.left + 16);
      expect(cardRect.right, listRect.right - 16);
      final reminderSwitch = switchFor('Promemoria Instagram');
      expect(reminderSwitch.thumbColor?.resolve({}), Colors.white);
      expect(reminderSwitch.activeTrackColor, const Color(0xFF0381FE));
      expect(reminderSwitch.inactiveTrackColor, const Color(0xFFB6B6BB));
      expect(reminderSwitch.trackOutlineColor?.resolve({}), Colors.transparent);
      for (final interval in [3, 6, 1]) {
        final selector = find.byType(ReminderIntervalSelector);
        await tester.ensureVisible(selector);
        expect(find.text('Ogni mese'), findsWidgets);
        expect(find.text('Ogni 3 mesi'), findsWidgets);
        expect(find.text('Ogni 6 mesi'), findsWidgets);
        await tester.tap(find.byKey(ValueKey('reminder-months-$interval')));
        await tester.pumpAndSettle();
        expect(app.reminderIntervalMonths, interval);
        expect(app.monthlyReminder, isFalse);
        expect(calls.last.method, 'setIntervalMonths');
        expect(calls.last.arguments, interval);
      }
      expect(calls.where((c) => c.method == 'setEnabled'), isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      app.dispose();
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('timeline shows dated losses even for whitelisted profiles', (
    tester,
  ) async {
    final app = TimelineProvider([
      UnfollowInterval(snapshot(1, ['kept', 'lost']), snapshot(2, ['kept'])),
    ]);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: app),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: TimelineScreen())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('01/01/2026'), findsOneWidget);
    expect(find.text('01/02/2026'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Timeline'));
    expect(title.style?.fontSize, 36);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(find.byIcon(Icons.timeline), findsOneWidget);
    expect(find.text('@lost'), findsOneWidget);
    expect(find.text('@kept'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    app.dispose();
  });

  testWidgets(
    'timeline axis stays aligned on narrow screens and profiles stay lazy',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final app = TimelineProvider([
        UnfollowInterval(
          snapshot(2, List.generate(1000, (i) => 'long_profile_name_$i')),
          snapshot(3, []),
        ),
        UnfollowInterval(snapshot(1, ['earlier']), snapshot(2, [])),
      ]);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppProvider>.value(value: app),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.samsungLightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const Scaffold(body: TimelineScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Compare the axis after bringing profile rows into the viewport.
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
      final nodes = find.byKey(const ValueKey('timeline-node'));
      expect(nodes, findsAtLeastNWidgets(2));
      final centers = nodes
          .evaluate()
          .map((element) => tester.getCenter(find.byWidget(element.widget)).dx)
          .toList();
      expect(centers.every((x) => (x - centers.first).abs() < 0.01), isTrue);
      expect(find.text('@long_profile_name_999'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      app.dispose();
    },
  );

  test('reminder state follows native permissions and cancellation', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('com.simpledevperson.instalander/reminders');
    var allowed = false;
    var enabled = false;
    var months = 1;
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'isEnabled') return enabled;
          if (call.method == 'getIntervalMonths') return months;
          if (call.method == 'setIntervalMonths') {
            months = call.arguments as int;
            return null;
          }
          enabled = call.arguments == true && allowed;
          return enabled;
        });
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    final app = AppProvider();
    expect(await app.setMonthlyReminder(true), isFalse);
    expect(app.monthlyReminder, isFalse);
    allowed = true;
    expect(await app.setMonthlyReminder(true), isTrue);
    expect(app.monthlyReminder, isTrue);
    expect(await ReminderService.isEnabled(), isTrue);
    for (final interval in [3, 6, 1]) {
      await app.setReminderIntervalMonths(interval);
      expect(app.reminderIntervalMonths, interval);
      expect(await ReminderService.getIntervalMonths(), interval);
      expect(app.monthlyReminder, isTrue);
    }
    await expectLater(app.setReminderIntervalMonths(2), throwsArgumentError);
    expect(app.reminderIntervalMonths, 1);
    expect(await app.setMonthlyReminder(false), isTrue);
    expect(app.monthlyReminder, isFalse);
    expect(calls.last.arguments, isFalse);
    app.dispose();
  });
}
