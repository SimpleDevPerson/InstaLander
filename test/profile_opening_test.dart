import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/settings_screen.dart';
import 'package:instalander/services/profile_launcher.dart';
import 'package:instalander/widgets/settings_toggle_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.simpledevperson.instalander/profiles');
  const paths = MethodChannel('plugins.flutter.io/path_provider');
  const reminders = MethodChannel('com.simpledevperson.instalander/reminders');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    messenger.setMockMethodCallHandler(reminders, (call) async {
      return switch (call.method) {
        'getIntervalMonths' => 1,
        'isEnabled' || 'setEnabled' => false,
        _ => null,
      };
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(paths, null);
    messenger.setMockMethodCallHandler(reminders, null);
  });

  test(
    'profile destination defaults to Instagram and persists across restarts',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'profile_preference_',
      );
      addTearDown(() => directory.delete(recursive: true));
      messenger.setMockMethodCallHandler(paths, (_) async => directory.path);
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return true;
      });
      final app = AppProvider();
      addTearDown(app.dispose);
      expect(await app.openProfile('example'), isTrue);
      expect(calls.last.arguments, {'username': 'example', 'inBrowser': false});
      await app.setOpenProfilesInBrowser(true);
      expect(app.autoWhitelistOnImport, isTrue);
      await app.setAutoWhitelistOnImport(false);
      final restarted = AppProvider();
      addTearDown(restarted.dispose);
      await restarted.initialize();
      expect(restarted.errorMessage, isNull);
      expect(restarted.openProfilesInBrowser, isTrue);
      expect(restarted.autoWhitelistOnImport, isFalse);
      expect(await restarted.openProfile('example'), isTrue);
      expect(calls.last.arguments, {'username': 'example', 'inBrowser': true});
      await restarted.clearAllData();
      expect(restarted.openProfilesInBrowser, isFalse);
      expect(restarted.autoWhitelistOnImport, isTrue);
    },
  );

  test('failed or unsupported profile opening reports failure', () async {
    expect(await ProfileLauncher.open('example', inBrowser: true), isFalse);
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'unavailable');
    });
    expect(await ProfileLauncher.open('example', inBrowser: false), isFalse);
  });

  testWidgets('settings switch saves the browser choice', (tester) async {
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
    final label = find.text('Apri i profili nel browser');
    await tester.scrollUntilVisible(label, 200);
    await tester.pumpAndSettle();
    final toggle = find.descendant(
      of: find.ancestor(of: label, matching: find.byType(SettingsToggleTile)),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(toggle).value, isFalse);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(toggle).value, isTrue);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        'open_profiles_in_browser',
      ),
      isTrue,
    );
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(app.openProfilesInBrowser, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    app.dispose();
  });
}
