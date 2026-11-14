import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/services/reminder_service.dart';
import 'package:instalander/widgets/debug_notification_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.simpledevperson.instalander/reminders');

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'immediate and arbitrary delayed tests use separate native commands',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return call.method == 'cancelDebugNotification' ? null : true;
          });
      expect(await ReminderService.showDebugNotification(), isTrue);
      expect(
        await ReminderService.scheduleDebugNotification(
          const Duration(milliseconds: 1234567),
        ),
        isTrue,
      );
      expect(calls.map((c) => c.method), [
        'showDebugNotification',
        'scheduleDebugNotification',
      ]);
      expect(calls.last.arguments, 1234567);
      await expectLater(
        ReminderService.scheduleDebugNotification(Duration.zero),
        throwsArgumentError,
      );
      await ReminderService.cancelDebugNotification();
      expect(calls.last.method, 'cancelDebugNotification');
    },
  );

  testWidgets('dialog validates delay and accepts custom decimal values', (
    tester,
  ) async {
    Duration? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                selected = await showDialog<Duration>(
                  context: context,
                  builder: (_) => const DebugNotificationDialog(),
                );
              },
              child: const Text('Apri'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '-1');
    await tester.tap(find.text('Programma'));
    await tester.pumpAndSettle();
    expect(find.text('Inserisci un tempo positivo valido.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '1,25');
    await tester.tap(find.text('Secondi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Minuti').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Programma'));
    await tester.pumpAndSettle();
    expect(selected, const Duration(seconds: 75));
  });
}
