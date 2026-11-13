import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/models/user.dart';
import 'package:instalander/models/username_change.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/settings_screen.dart';
import 'package:instalander/screens/whitelist_screen.dart';
import 'package:instalander/theme/app_theme.dart';
import 'package:instalander/widgets/instagram_export_notice.dart';
import 'package:instalander/widgets/username_changes_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final (name, theme) in [
    ('Material light', AppTheme.lightTheme),
    ('Material dark', AppTheme.darkTheme),
    ('One UI light', AppTheme.samsungLightTheme),
    ('One UI dark', AppTheme.samsungDarkTheme),
  ]) {
    testWidgets('Popup actions meet 4.5:1 contrast in $name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: UsernameChangesDialog(
              candidates: [
                UsernameChangeCandidate(
                  InstagramUser(username: 'old', timestamp: 1700000000),
                  [InstagramUser(username: 'new', timestamp: 1700000000)],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      _expectReadableButtons(tester, expectedCount: 3);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showInstagramExportNoticeIfNeeded(context),
                child: const Text('Apri'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();
      _expectReadableButtons(tester, expectedCount: 1);
      await tester.tap(find.text('Ho capito'));
      await tester.pumpAndSettle();

      final app = _WhitelistProvider();
      await app.enableDebugTools();
      Future<void> showScreen(Widget screen) async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AppProvider>.value(value: app),
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ],
            child: MaterialApp(theme: theme, home: screen),
          ),
        );
        await tester.pumpAndSettle();
      }

      await showScreen(const SettingsScreen());
      await tester.scrollUntilVisible(find.text('Cancella tutti i dati'), 250);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Cancella tutti i dati'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancella tutti i dati'));
      await tester.pumpAndSettle();
      _expectReadableButtons(tester, expectedCount: 2);
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      await showScreen(const WhitelistScreen());
      await tester.tap(find.byTooltip('Rimuovi dalla whitelist'));
      await tester.pumpAndSettle();
      _expectReadableButtons(tester, expectedCount: 2);
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Svuota whitelist'));
      await tester.pumpAndSettle();
      _expectReadableButtons(tester, expectedCount: 2);
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDatePicker(
                  context: context,
                  initialDate: DateTime(2026, 11, 13),
                  firstDate: DateTime(2010),
                  lastDate: DateTime(2026, 11, 13),
                  cancelText: 'Annulla',
                  confirmText: 'Importa',
                ),
                child: const Text('Data esportazione'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Data esportazione'));
      await tester.pumpAndSettle();
      _expectReadableButtons(tester, expectedCount: 2);
      expect(
        _contrast(theme.colorScheme.onPrimary, theme.colorScheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(theme.colorScheme.onError, theme.colorScheme.error),
        greaterThanOrEqualTo(4.5),
      );
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      app.dispose();
    });
  }
}

void _expectReadableButtons(WidgetTester tester, {required int expectedCount}) {
  final dialog = find.byType(Dialog);
  final buttons = find.descendant(
    of: dialog,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is TextButton ||
          widget is FilledButton ||
          widget is ElevatedButton ||
          widget is OutlinedButton,
    ),
  );
  expect(buttons, findsNWidgets(expectedCount));
  for (final button in buttons.evaluate()) {
    final buttonFinder = find.byWidget(button.widget);
    final label = find
        .descendant(of: buttonFinder, matching: find.byType(RichText))
        .first;
    final foreground = tester.widget<RichText>(label).text.style!.color!;
    var background = Theme.of(button).scaffoldBackgroundColor;
    final materials = tester.widgetList<Material>(
      find.ancestor(of: label, matching: find.byType(Material)),
    );
    for (final material in materials.toList().reversed) {
      if (material.color case final Color color) {
        background = Color.alphaBlend(color, background);
      }
    }
    expect(
      _contrast(Color.alphaBlend(foreground, background), background),
      greaterThanOrEqualTo(4.5),
      reason:
          'Contrast of ${tester.widget<RichText>(label).text.toPlainText()}',
    );
  }
}

double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  return first > second
      ? (first + 0.05) / (second + 0.05)
      : (second + 0.05) / (first + 0.05);
}

class _WhitelistProvider extends AppProvider {
  @override
  Set<String> get whitelist => {'example'};
}
