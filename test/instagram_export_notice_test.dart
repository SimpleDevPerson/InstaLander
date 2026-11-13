import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/theme/app_theme.dart';
import 'package:instalander/widgets/instagram_export_notice.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpNoticeButton(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.samsungLightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showInstagramExportNoticeIfNeeded(context),
              child: const Text('Importazione completata'),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('explains ghost profiles once, including across restarts', (
    tester,
  ) async {
    await pumpNoticeButton(tester);
    await tester.tap(find.text('Importazione completata'));
    await tester.pumpAndSettle();

    expect(find.text('Possibili profili “fantasma”'), findsOneWidget);
    expect(find.textContaining('account che non segui più'), findsOneWidget);
    expect(find.textContaining('sono stati eliminati'), findsOneWidget);
    expect(find.textContaining('non da un errore dell’app'), findsOneWidget);

    await tester.tap(find.text('Ho capito'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Importazione completata'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpNoticeButton(tester);
    await tester.tap(find.text('Importazione completata'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    // Clearing app data clears preferences and allows a fresh first import.
    await (await SharedPreferences.getInstance()).clear();
    await tester.tap(find.text('Importazione completata'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Ho capito'));
    await tester.pumpAndSettle();
  });
}
