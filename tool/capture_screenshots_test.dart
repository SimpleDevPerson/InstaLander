// Run with: flutter test tool/capture_screenshots_test.dart
// Renders the real app widgets with synthetic data; never reads device data.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/models/import_snapshot.dart';
import 'package:instalander/models/user.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/main_screen.dart';
import 'package:instalander/services/ads_service.dart';
import 'package:instalander/services/data_service.dart';
import 'package:instalander/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ScreenshotData extends AppProvider {
  static final _date = DateTime(2026, 10, 1);
  static const _names = [
    'demo_luca',
    'demo_marta',
    'demo_marco',
    'demo_alice',
    'demo_giulia',
    'demo_davide',
    'demo_elena',
    'demo_paolo',
    'demo_sofia',
    'demo_matteo',
    'demo_sara',
    'demo_pietro',
    'demo_anna',
    'demo_andrea',
    'demo_giada',
    'demo_nicolo',
    'demo_federica',
    'demo_simone',
    'demo_aurora',
    'demo_lorenzo',
    'demo_chiara',
    'demo_tommaso',
    'demo_camilla',
    'demo_leonardo',
  ];
  final _profiles = {
    for (var i = 0; i < _names.length; i++)
      _names[i]: InstagramUser(
        username: _names[i],
        timestamp: _date.add(Duration(days: i)).millisecondsSinceEpoch ~/ 1000,
      ),
  };

  @override
  Future<void> initialize() async {}
  @override
  bool get isLoading => false;
  @override
  bool get hasData => true;
  @override
  bool get hasFollowersFile => true;
  @override
  bool get hasFollowingFile => true;
  @override
  bool get hasPartialData => false;
  @override
  bool get shouldShowOnboarding => false;
  @override
  String? get errorMessage => null;
  @override
  bool get monthlyReminder => true;
  @override
  int get reminderIntervalMonths => 3;
  @override
  Map<String, InstagramUser> get following => _profiles;
  @override
  Map<String, InstagramUser> get followers => {
    ...Map.fromEntries(_profiles.entries.take(10)),
    for (var i = 0; i < 8; i++)
      'demo_follower_$i': InstagramUser(
        username: 'demo_follower_$i',
        timestamp: _date.millisecondsSinceEpoch ~/ 1000,
      ),
  };
  @override
  Set<String> get whitelist => {
    'demo_marta',
    'demo_luca',
    'demo_alice',
    'demo_giulia',
    'demo_davide',
    'demo_elena',
    'demo_paolo',
    'demo_sofia',
  };
  @override
  List<InstagramUser> get nonFollowers =>
      DataService.computeNonFollowers(followers, following, whitelist);
  @override
  List<InstagramUser> get sortedNonFollowers =>
      DataService.sortUsers(nonFollowers, currentSort);
  @override
  Map<String, int> get stats =>
      DataService.getStats(followers, following, whitelist);
  @override
  List<UnfollowInterval> get timeline {
    ImportSnapshot snapshot(int month, List<String> added) => ImportSnapshot(
      date: DateTime(2026, month, 13),
      followersImported: true,
      hasFollowers: true,
      hasFollowing: true,
      followers: {
        ...followers,
        for (final name in added) name: _profiles[name]!,
      },
      following: following,
    );
    final latest = snapshot(11, []);
    final previous = snapshot(10, ['demo_sara', 'demo_pietro']);
    final oldest = snapshot(9, [
      'demo_sara',
      'demo_pietro',
      'demo_anna',
      'demo_andrea',
      'demo_giada',
    ]);
    return [
      UnfollowInterval(previous, latest),
      UnfollowInterval(oldest, previous),
    ];
  }
}

Future<void> _loadFonts() async {
  final configFile = File('.dart_tool/package_config.json');
  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final flutter = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((p) => p['name'] == 'flutter');
  final packageUri = configFile.absolute.uri.resolve(
    flutter['rootUri'] as String,
  );
  final sdk = Directory.fromUri(packageUri).parent.parent;
  final fontDirectory = '${sdk.path}/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final weight in ['regular', 'medium', 'bold']) {
    roboto.addFont(
      File(
        '$fontDirectory/roboto-$weight.ttf',
      ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
    );
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      File(
        '$fontDirectory/materialicons-regular.otf',
      ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
    );
  await icons.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);
  testWidgets('capture public screenshots using synthetic data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 912);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // This widget-test runner lives outside test/ to keep normal tests read-only.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      'app_theme_style': 0,
      'app_brightness_mode': 2,
      'app_icon_style': 1,
      'ads_enabled': false,
    });
    AdsService.instance.adsEnabled.value = false;
    final data = _ScreenshotData();
    final theme = ThemeProvider();
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: ColoredBox(
          color: const Color(0xFF111111),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider<AppProvider>.value(value: data),
                    ChangeNotifierProvider<ThemeProvider>.value(value: theme),
                  ],
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.samsungDarkTheme,
                    home: const MainScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/images/app_icon_dark.jpg'),
        boundaryKey.currentContext!,
      ),
    );
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/images/app_icon_original.png'),
        boundaryKey.currentContext!,
      ),
    );
    await tester.pumpAndSettle();

    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      // The test engine uses square Ahem glyphs for TextStyles without a
      // family. Match Android's Roboto fallback in the capture render tree,
      // leaving production widgets and the app's explicit font styles intact.
      void useAndroidFont(RenderObject object) {
        if (object is RenderParagraph && object.text is TextSpan) {
          final span = object.text as TextSpan;
          if (span.style?.fontFamily == null ||
              span.style?.fontFamily == 'Ahem') {
            object.text = TextSpan(
              text: span.text,
              children: span.children,
              style: (span.style ?? const TextStyle()).copyWith(
                fontFamily: 'Roboto',
              ),
              recognizer: span.recognizer,
              semanticsLabel: span.semanticsLabel,
            );
          }
        }
        object.visitChildren(useAndroidFont);
      }

      useAndroidFont(boundary);
      await tester.pump();
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 3);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('docs/screenshots');
        await directory.create(recursive: true);
        await File(
          '${directory.path}/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      debugPrint('Screenshot saved: $name');
    }

    await capture('report');
    await tester.tap(find.byIcon(Icons.timeline_outlined).hitTestable());
    await capture('timeline');
    await tester.tap(find.byIcon(Icons.favorite_outline).hitTestable());
    await capture('whitelist');
    await tester.tap(find.byIcon(Icons.settings_outlined).hitTestable());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Icona dell’app'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    // Begin at a complete section heading, without a cropped row above it.
    final iconSection = tester.element(find.text('Icona dell’app'));
    await Scrollable.of(
      iconSection,
    ).position.ensureVisible(iconSection.findRenderObject()!, alignment: 0.03);
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni').hitTestable(), findsOneWidget);
    await capture('reminders');
    await tester.pumpWidget(const SizedBox.shrink());
    data.dispose();
    theme.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
