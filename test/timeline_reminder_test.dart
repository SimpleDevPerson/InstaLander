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
import 'package:instalander/services/debug_data_service.dart';
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
  TimelineProvider(this.intervals, {this.files = const []});
  final List<UnfollowInterval> intervals;
  List<ImportFileEntry> files;
  @override
  bool get isLoading => false;
  @override
  late final Future<List<UnfollowInterval>> savedTimeline = Future.value(
    intervals,
  );
  @override
  Set<String> get whitelist => {'lost'};
  @override
  late Future<List<ImportFileEntry>> savedImports = Future.value(files);

  @override
  Future<void> removeImportedFile(ImportFileEntry entry) async {
    files = files.where((file) => file != entry).toList();
    savedImports = Future.value(files);
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'file timeline groups reimported following with followers from the same day',
    (tester) async {
      final date = DateTime(2026, 11, 23);
      final app = TimelineProvider(
        [],
        files: [
          (
            snapshotIndex: 2,
            fileIndex: 0,
            date: DateTime(2026, 11, 23, 18),
            name: 'following.json',
            fingerprint: 'two',
          ),
          (
            snapshotIndex: 1,
            fileIndex: 0,
            date: date,
            name: 'followers_1.json',
            fingerprint: 'one',
          ),
          (
            snapshotIndex: 0,
            fileIndex: 0,
            date: DateTime(2026, 11, 22),
            name: 'followers_2.json',
            fingerprint: 'three',
          ),
        ],
      );
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
      expect(find.text('followers_1.json'), findsNothing);
      await tester.tap(find.text('File importati'));
      await tester.pumpAndSettle();
      final followers = find.text('followers_1.json');
      final following = find.text('following.json');
      final otherBatch = find.text('followers_2.json');
      expect(find.textContaining('2 file caricati'), findsOneWidget);
      expect(find.textContaining('1 file caricato'), findsOneWidget);
      expect(tester.getTopLeft(followers).dx, tester.getTopLeft(following).dx);
      expect(
        tester.getCenter(followers).dy,
        lessThan(tester.getCenter(following).dy),
      );
      expect(
        tester.getCenter(otherBatch).dy,
        greaterThan(tester.getCenter(following).dy),
      );
      final nodes = find.byKey(const ValueKey('timeline-node'));
      expect(nodes, findsNWidgets(5));
      expect({
        for (var i = 0; i < 5; i++) tester.getCenter(nodes.at(i)).dx,
      }, hasLength(1));
      final colors = Theme.of(tester.element(followers)).colorScheme;
      final item = find.ancestor(
        of: followers,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.color == colors.surfaceContainerLow,
        ),
      );
      final remove = find.descendant(
        of: item,
        matching: find.byIcon(Icons.close),
      );
      final cardBounds = tester.getRect(item);
      final closeBounds = tester.getRect(remove);
      expect(closeBounds.top, greaterThan(cardBounds.top));
      expect(closeBounds.right, lessThan(cardBounds.right));
      final jsonIcon = find.descendant(
        of: item,
        matching: find.byIcon(Icons.data_object),
      );
      expect(tester.widget<Icon>(jsonIcon).color, colors.onSurfaceVariant);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();
      expect(item, findsOneWidget);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Rimuovi'));
      await tester.pumpAndSettle();
      expect(find.text('followers_1.json'), findsNothing);
      expect(find.text('following.json'), findsOneWidget);
      expect(find.textContaining('1 file caricato'), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox.shrink());
      app.dispose();
    },
  );

  testWidgets('timeline groups both usernames in the tagged rename card', (
    tester,
  ) async {
    final interval = DebugDataService().profileChanges();
    final rename = interval.profiles.first;
    final app = TimelineProvider([interval]);
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

    final card = find.ancestor(
      of: find.text('Nome cambiato'),
      matching: find.byType(InkWell),
    );
    for (final label in [
      '@${rename.user.username}',
      'Prima: @${rename.previousUsername}',
    ]) {
      expect(
        find.descendant(of: card, matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(find.text('Possibile cancellazione'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    app.dispose();
  });

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
      await tester.scrollUntilVisible(find.text('Notifiche'), 250);
      await tester.pumpAndSettle();
      expect(find.text('Notifiche'), findsOneWidget);
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
      await tester.scrollUntilVisible(find.text('Controllo automatico'), 150);
      expect(find.text('Controllo automatico'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      app.dispose();
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'timeline separates gains before losses with contrast in $brightness',
      (tester) async {
        final kept = List.generate(470, (index) => 'kept_$index');
        final interval = UnfollowInterval(
          snapshot(1, [...kept, 'lost']),
          snapshot(2, [...kept, ...List.generate(9, (index) => 'new_$index')]),
        );
        expect(interval.newFollowerCount, 9);
        expect(interval.intermediateFollowerCount, 480);
        final app = TimelineProvider([interval]);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AppProvider>.value(value: app),
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ],
            child: MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: const Scaffold(body: TimelineScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final (key, label, from, to) in [
          ('timeline-follower-gains', '9 nuovi', '471', '480'),
          ('timeline-follower-losses', '1 persi', '480', '479'),
        ]) {
          final step = find.byKey(ValueKey(key));
          final color = key == 'timeline-follower-gains'
              ? Colors.green.shade800
              : Colors.red.shade800;
          final colors = Theme.of(tester.element(step)).colorScheme;
          final normalColor = colors.onSurfaceVariant;
          final pill = tester.widget<DecoratedBox>(
            find.descendant(of: step, matching: find.byType(DecoratedBox)),
          );
          final decoration = pill.decoration as ShapeDecoration;
          expect(decoration.color, isNot(color));
          expect(decoration.shape, isA<StadiumBorder>());
          expect(
            (decoration.shape as StadiumBorder).side.color,
            isNot(decoration.color),
          );
          expect(
            tester.widget<Text>(find.text(label)).style?.color,
            colors.onSurface,
          );
          final foregroundLuminance = colors.onSurface.computeLuminance();
          final backgroundLuminance = decoration.color!.computeLuminance();
          final lighter = foregroundLuminance > backgroundLuminance
              ? foregroundLuminance
              : backgroundLuminance;
          final darker = foregroundLuminance < backgroundLuminance
              ? foregroundLuminance
              : backgroundLuminance;
          expect((lighter + 0.05) / (darker + 0.05), greaterThanOrEqualTo(4.5));
          expect(
            tester
                .widget<Icon>(
                  find.descendant(
                    of: step,
                    matching: find.byIcon(Icons.arrow_forward_rounded),
                  ),
                )
                .color,
            normalColor,
          );
          for (final text in [label, from, to]) {
            final item = find.descendant(of: step, matching: find.text(text));
            expect(item, findsOneWidget);
            expect(
              tester.widget<Text>(item).style?.color ??
                  DefaultTextStyle.of(tester.element(item)).style.color,
              text == label ? colors.onSurface : normalColor,
            );
          }
          expect(
            find.descendant(of: step, matching: find.text('(')),
            findsNothing,
          );
          expect(
            find.descendant(of: step, matching: find.text(')')),
            findsNothing,
          );
        }
        expect(
          tester.getRect(find.text('9 nuovi')).bottom,
          lessThan(tester.getRect(find.text('1 persi')).top),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        app.dispose();
      },
    );
  }

  testWidgets(
    'timeline description opens from help after the last item in both views',
    (tester) async {
      final app = TimelineProvider(
        [
          UnfollowInterval(
            snapshot(1, ['kept', 'lost']),
            snapshot(2, ['kept']),
          ),
        ],
        files: [
          (
            snapshotIndex: 0,
            fileIndex: 0,
            date: DateTime(2026, 1, 1),
            name: 'followers_1.json',
            fingerprint: 'help-test',
          ),
        ],
      );
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
      for (final filesView in [false, true]) {
        if (filesView) {
          await tester.tap(find.text('File importati'));
          await tester.pumpAndSettle();
        }
        final description = find.textContaining(
          'La Timeline confronta due esportazioni',
        );
        expect(description, findsNothing);
        final help = find.byKey(const ValueKey('timeline-help'));
        final bounds = tester.getRect(find.byType(TimelineScreen));
        expect(tester.getCenter(help).dx, lessThan(bounds.center.dx));
        final lastItem = find.text(filesView ? 'followers_1.json' : '@lost');
        expect(
          tester.getRect(help).top,
          greaterThan(tester.getRect(lastItem).bottom),
        );
        expect(
          find.ancestor(of: help, matching: find.byType(Scrollable)),
          findsOneWidget,
        );
        await tester.tap(help);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Come leggere la Timeline'), findsOneWidget);
        expect(description, findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(description, findsNothing);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      app.dispose();
    },
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
    final counter = find.byKey(const ValueKey('timeline-follower-count'));
    expect(counter, findsOneWidget);
    expect(find.text('0 nuovi'), findsNothing);
    expect(find.byKey(const ValueKey('timeline-follower-gains')), findsNothing);
    expect(find.text('1 persi'), findsOneWidget);
    final losses = find.byKey(const ValueKey('timeline-follower-losses'));
    final arrow = find.descendant(
      of: losses,
      matching: find.byIcon(Icons.arrow_forward_rounded),
    );
    for (final count in ['2', '1']) {
      final number = find.descendant(of: losses, matching: find.text(count));
      expect(tester.getCenter(arrow).dy, tester.getCenter(number).dy);
    }
    expect(
      tester.getRect(counter).top,
      greaterThan(
        tester.getRect(find.text('Confronto tra esportazioni')).bottom,
      ),
    );
    expect(
      tester.getRect(counter).bottom,
      lessThan(tester.getRect(find.text('@lost')).top),
    );
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
      await tester.scrollUntilVisible(find.text('@long_profile_name_0'), 150);
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
