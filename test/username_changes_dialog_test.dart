import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/models/user.dart';
import 'package:instalander/models/username_change.dart';
import 'package:instalander/widgets/username_changes_dialog.dart';

void main() {
  testWidgets(
    'rename dialog requires an explicit choice and supports ignoring and cancelling',
    (tester) async {
      Map<String, String>? result;
      final candidates = [
        UsernameChangeCandidate(
          InstagramUser(username: 'old', timestamp: 1700000000),
          [InstagramUser(username: 'new', timestamp: 1700000000)],
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<Map<String, String>>(
                    context: context,
                    builder: (_) =>
                        UsernameChangesDialog(candidates: candidates),
                  );
                },
                child: const Text('Importa'),
              ),
            ),
          ),
        ),
      );
      Future<void> open() async {
        await tester.tap(find.text('Importa'));
        await tester.pumpAndSettle();
      }

      await open();
      expect(find.text('Non associare'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rename-old')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('@new').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Conferma e importa'));
      await tester.pumpAndSettle();
      expect(result, {'old': 'new'});

      await open();
      await tester.tap(find.text('Ignora tutte'));
      await tester.pumpAndSettle();
      expect(result, isEmpty);

      await open();
      await tester.tap(find.text('Annulla importazione'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
