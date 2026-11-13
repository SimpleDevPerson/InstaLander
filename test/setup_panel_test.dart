import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/theme/app_theme.dart';
import 'package:instalander/widgets/setup_panel.dart';

void main() {
  for (final theme in [
    AppTheme.samsungLightTheme,
    AppTheme.samsungDarkTheme,
    AppTheme.lightTheme,
    AppTheme.darkTheme,
  ]) {
    testWidgets(
      'Setup remains usable with narrow screens and large text ${theme.hashCode}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        for (final largeText in [false, true]) {
          tester.view.physicalSize = Size(largeText ? 320 : 412, 900);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(largeText ? 2 : 1)),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SetupPanel(
                    onShowGuide: () {},
                    onLoadJson: () {},
                    onLoadArchive: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final json = find.text('Carica JSON');
          final zip = find.text('Carica archivio ZIP');
          if (largeText) {
            await tester.ensureVisible(zip);
            await tester.pumpAndSettle();
            expect(
              tester.getTopLeft(zip).dy,
              greaterThan(tester.getTopLeft(json).dy),
            );
          } else {
            final jsonButton = find.ancestor(
              of: json,
              matching: find.byType(OutlinedButton),
            );
            final zipButton = find.ancestor(
              of: zip,
              matching: find.byType(OutlinedButton),
            );
            expect(
              tester.getTopLeft(jsonButton).dy,
              tester.getTopLeft(zipButton).dy,
            );
            expect(
              tester.getSize(jsonButton).height,
              tester.getSize(zipButton).height,
            );
          }
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}
