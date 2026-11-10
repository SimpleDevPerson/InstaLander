import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_follower_checker/main.dart';
import 'package:instagram_follower_checker/providers/app_provider.dart';
import 'package:instagram_follower_checker/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App builds without crashing', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const InstagramFollowerCheckerApp(),
      ),
    );

    // Verify the app renders
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
