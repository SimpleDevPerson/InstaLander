import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:instalander/main.dart';
import 'package:instalander/models/user.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/main_screen.dart';
import 'package:instalander/screens/onboarding_screen.dart';
import 'package:instalander/screens/settings_screen.dart';
import 'package:instalander/screens/whitelist_screen.dart';
import 'package:instalander/services/ads_service.dart';
import 'package:instalander/theme/app_theme.dart';
import 'package:instalander/widgets/native_ad_card.dart';
import 'package:instalander/widgets/one_ui_brightness_selector.dart';
import 'package:instalander/widgets/stats_counter.dart';
import 'package:instalander/widgets/user_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('One UI brightness selector saves all three modes', (
    tester,
  ) async {
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OneUiBrightnessSelector), findsOneWidget);
    expect(find.byType(SegmentedButton<AppBrightnessMode>), findsNothing);
    for (final mode in [
      AppBrightnessMode.dark,
      AppBrightnessMode.light,
      AppBrightnessMode.system,
    ]) {
      final button = find.byKey(ValueKey('brightness-mode-${mode.name}'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(themeProvider.brightnessMode, mode);
      expect(
        tester
            .widget<OneUiBrightnessSelector>(
              find.byType(OneUiBrightnessSelector),
            )
            .value,
        mode,
      );
      expect(
        (await SharedPreferences.getInstance()).getInt('app_brightness_mode'),
        mode.index,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    themeProvider.dispose();
  });

  test('App icon choice is persisted', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final themeProvider = ThemeProvider();
    await themeProvider.setAppIconStyle(AppIconStyle.dark);

    final restoredProvider = ThemeProvider();
    await Future<void>.delayed(Duration.zero);

    expect(restoredProvider.appIconStyle, AppIconStyle.dark);
  });

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

  testWidgets('Onboarding advances by button and swipe', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onComplete: () async => completed = true),
      ),
    );

    expect(find.text('Il tuo report, privato.').hitTestable(), findsOneWidget);
    final title = tester.widget<Text>(find.text('InstaLander'));
    expect(title.style?.fontSize, 32);
    expect(title.style?.fontWeight, FontWeight.w800);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(
      find.text('Carica e consulta il report').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text('Avanti').hitTestable());
    await tester.pumpAndSettle();
    expect(
      find.text('Scegli chi tenere nella whitelist').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text('Avanti').hitTestable());
    await tester.pumpAndSettle();
    expect(
      find.text('Segui i cambiamenti nella timeline').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text('Avanti').hitTestable());
    await tester.pumpAndSettle();
    expect(
      find.text('Ricordati di aggiornare i dati').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text("Procedi nell'app").hitTestable());
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });

  testWidgets('Onboarding button labels meet contrast on every theme', (
    tester,
  ) async {
    for (final theme in [
      AppTheme.lightTheme,
      AppTheme.darkTheme,
      AppTheme.samsungLightTheme,
      AppTheme.samsungDarkTheme,
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: OnboardingScreen(
            key: ValueKey(theme.brightness),
            onComplete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nextButton = tester.widget<FilledButton>(find.byType(FilledButton));
      final buttonTextColor = nextButton.style!.foregroundColor!.resolve({})!;
      expect(
        _contrastRatio(buttonTextColor, theme.colorScheme.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'Next button text contrast for ${theme.brightness}',
      );

      await tester.tap(find.text('Avanti').hitTestable());
      await tester.pumpAndSettle();

      final backButton = tester.widget<TextButton>(find.byType(TextButton));
      final backTextColor = backButton.style!.foregroundColor!.resolve({})!;
      expect(
        _contrastRatio(backTextColor, theme.scaffoldBackgroundColor),
        greaterThanOrEqualTo(4.5),
        reason: 'Back button text contrast for ${theme.brightness}',
      );
    }
  });

  testWidgets('Setup hides the report count before files are loaded', (
    tester,
  ) async {
    await tester.pumpWidget(_mainScreen(_TestAppProvider()));
    await tester.pump();

    expect(find.text('InstaLander'), findsOneWidget);
    final header = find.ancestor(
      of: find.text('InstaLander'),
      matching: find.byType(Container),
    );
    expect(tester.widget<Container>(header.first).decoration, isNull);
    expect(
      find.descendant(of: header.first, matching: find.byType(Image)),
      findsOneWidget,
    );
    expect(tester.widget<Text>(find.text('InstaLander')).style?.fontSize, 34);
    final iconRect = tester.getRect(
      find.descendant(of: header.first, matching: find.byType(Image)),
    );
    final titleRect = tester.getRect(find.text('InstaLander'));
    expect(
      (iconRect.left + titleRect.right) / 2,
      closeTo(tester.getCenter(header.first).dx, 0.01),
    );
    expect(find.byType(StatsCounter), findsNothing);
    expect(find.text('Da controllare: '), findsNothing);
    expect(find.textContaining('Puoi scaricarli da Instagram'), findsNothing);
    expect(
      find.text('Come esportare le informazioni da Instagram'),
      findsOneWidget,
    );
    expect(find.text('followers_*.json'), findsOneWidget);
    expect(find.text('following_*.json'), findsOneWidget);
  });

  testWidgets('Export instructions open only from the setup guide button', (
    tester,
  ) async {
    await tester.pumpWidget(_mainScreen(_TestAppProvider()));
    await tester.pumpAndSettle();
    expect(find.text('Apri il Centro gestione account'), findsNothing);

    final guideButton = find.text(
      'Come esportare le informazioni da Instagram',
    );
    await tester.ensureVisible(guideButton);
    await tester.tap(guideButton);
    await tester.pumpAndSettle();
    expect(
      find.text('Apri il Centro gestione account').hitTestable(),
      findsOneWidget,
    );
    expect(find.text('1/4'), findsOneWidget);
    for (final title in [
      'Richiedi una copia dei dati',
      'Scegli il formato JSON',
      'Scarica ed estrai l’archivio',
    ]) {
      await tester.tap(find.text('Avanti').hitTestable());
      await tester.pumpAndSettle();
      expect(find.text(title).hitTestable(), findsOneWidget);
    }

    await tester.tap(find.text('Torna al report'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('Configura il report'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        'onboarding_completed_v2',
      ),
      isNull,
    );
  });

  testWidgets('Finishing onboarding after a settings reset opens the report', (
    tester,
  ) async {
    final provider = _RestartableOnboardingProvider();
    await tester.pumpWidget(_mainScreen(provider));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined).hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni').hitTestable(), findsOneWidget);

    await provider.clearAllData();
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    for (var step = 0; step < 4; step++) {
      await tester.tap(find.text('Avanti').hitTestable());
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text("Procedi nell'app"));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('Configura il report').hitTestable(), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        'onboarding_completed_v2',
      ),
      isTrue,
    );
  });

  testWidgets('A single JSON file asks for the missing file', (tester) async {
    await tester.pumpWidget(
      _mainScreen(_TestAppProvider(hasFollowersFile: true)),
    );
    await tester.pump();

    expect(find.text('Manca un file'), findsOneWidget);
    expect(find.textContaining('following_*.json'), findsOneWidget);
    expect(find.text('Errore'), findsNothing);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(StatsCounter), findsNothing);
  });

  testWidgets('Back from a secondary tab returns to the report', (
    tester,
  ) async {
    await tester.pumpWidget(_mainScreen(_TestAppProvider()));
    await tester.pump();

    final pageSwipeDistance =
        tester.view.physicalSize.width / tester.view.devicePixelRatio * 0.8;
    await tester.drag(find.byType(PageView), Offset(-pageSwipeDistance, 0));
    await tester.pumpAndSettle();
    expect(find.text('Timeline').hitTestable(), findsOneWidget);
    await tester.drag(find.byType(PageView), Offset(-pageSwipeDistance, 0));
    await tester.pumpAndSettle();
    expect(find.text('Whitelist').hitTestable(), findsOneWidget);
    await tester.drag(find.byType(PageView), Offset(-pageSwipeDistance, 0));
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni'), findsWidgets);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('InstaLander'), findsOneWidget);
  });

  testWidgets('Navigation skips the middle page when switching endpoints', (
    tester,
  ) async {
    await tester.pumpWidget(_mainScreen(_TestAppProvider()));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_outlined).hitTestable());
    await tester.pump();
    expect(find.text('Impostazioni').hitTestable(), findsOneWidget);
    expect(find.text('Whitelist').hitTestable(), findsNothing);

    await tester.tap(find.byIcon(Icons.analytics_outlined).hitTestable());
    await tester.pump();
    expect(find.text('InstaLander').hitTestable(), findsOneWidget);
    expect(find.text('Whitelist').hitTestable(), findsNothing);
  });

  testWidgets('Theme changes preserve the selected page and navbar index', (
    tester,
  ) async {
    final themeProvider = ThemeProvider();
    expect(themeProvider.isSamsungTheme, isTrue);
    expect(themeProvider.brightnessMode, AppBrightnessMode.system);

    await tester.pumpWidget(
      _mainScreen(_TestAppProvider(), themeProvider: themeProvider),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(themeProvider.isSamsungTheme, isTrue);
    final selectedSamsungIcon = tester.widget<Icon>(
      find.byIcon(Icons.analytics).first,
    );
    expect(
      selectedSamsungIcon.color,
      Theme.of(tester.element(find.byType(MainScreen))).colorScheme.onSurface,
    );

    final pageSwipeDistance =
        tester.view.physicalSize.width / tester.view.devicePixelRatio * 0.8;
    await tester.drag(find.byType(PageView), Offset(-pageSwipeDistance, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), Offset(-pageSwipeDistance, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), Offset(-pageSwipeDistance, 0));
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni'), findsWidgets);

    await themeProvider.setThemeStyle(AppThemeStyle.materialExpressive);
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    expect(navigationBar, findsOneWidget);
    expect(tester.widget<NavigationBar>(navigationBar).selectedIndex, 3);
    expect(find.text('Impostazioni'), findsWidgets);
    expect(
      tester.getSize(navigationBar).width,
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
    );
    expect(find.byType(SegmentedButton<AppBrightnessMode>), findsOneWidget);
    final segmentedButton = tester.widget<SegmentedButton<AppBrightnessMode>>(
      find.byType(SegmentedButton<AppBrightnessMode>),
    );
    final selectedBackground = segmentedButton.style!.backgroundColor!.resolve({
      WidgetState.selected,
    });
    expect(
      selectedBackground,
      Theme.of(tester.element(find.byType(MainScreen))).colorScheme.primary,
    );

    await tester.ensureVisible(find.text('Scuro'));
    await tester.tap(find.text('Scuro').hitTestable());
    await tester.pumpAndSettle();
    expect(themeProvider.brightnessMode, AppBrightnessMode.dark);
    expect(tester.widget<NavigationBar>(navigationBar).selectedIndex, 3);
    expect(find.text('Impostazioni'), findsWidgets);

    await themeProvider.setThemeStyle(AppThemeStyle.samsungOneUi);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Impostazioni'), findsWidgets);
    expect(find.byIcon(Icons.settings), findsWidgets);
    final samsungNavbar = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).boxShadow?.length == 2,
    );
    expect(samsungNavbar, findsOneWidget);
    expect(tester.getSize(samsungNavbar).width, 288);
    expect(find.byType(BackdropFilter), findsOneWidget);

    await themeProvider.setBrightnessMode(AppBrightnessMode.system);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('InstaLander'), findsOneWidget);
  });

  testWidgets('Loaded report shows its descriptive title', (tester) async {
    await tester.pumpWidget(
      _mainScreen(
        _TestAppProvider(
          hasData: true,
          hasFollowersFile: true,
          hasFollowingFile: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Il tuo unfollower report'), findsOneWidget);
    expect(find.text('InstaLander'), findsNothing);
    expect(find.byType(StatsCounter), findsOneWidget);
    final statusIcon = tester.widget<Icon>(find.byIcon(Icons.check_rounded));
    expect(statusIcon.size, 18);
    final sortLabel = tester.widget<Text>(find.text('Più recenti'));
    expect(sortLabel.maxLines, 1);
    expect(sortLabel.overflow, TextOverflow.ellipsis);
    expect(find.text('JSON'), findsOneWidget);
    expect(find.text('ZIP'), findsOneWidget);
    final sortDropdown = find.byType(PopupMenuButton<SortOption>);
    final sortBox = find.ancestor(
      of: sortDropdown,
      matching: find.byType(SizedBox),
    );
    expect(tester.getSize(sortBox.first).height, 56);
    final title = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.textSpan?.toPlainText() == 'Il tuo unfollower report',
      ),
    );
    final titleSpan = title.textSpan! as TextSpan;
    expect(title.style?.fontWeight, FontWeight.w400);
    expect(titleSpan.children![1].style?.fontWeight, FontWeight.w700);
    expect(titleSpan.children![0].style?.fontWeight, isNull);
    expect(titleSpan.children![2].style?.fontWeight, isNull);
    final jsonButton = find.widgetWithText(OutlinedButton, 'JSON');
    final zipButton = find.widgetWithText(OutlinedButton, 'ZIP');
    expect(tester.getSize(jsonButton).height, lessThanOrEqualTo(56));
    expect(tester.getSize(zipButton).height, lessThanOrEqualTo(56));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Scrolling reuses already built profile cards', (tester) async {
    final users = List.generate(
      1000,
      (index) => InstagramUser(username: 'profile_$index', timestamp: index),
    );
    await tester.pumpWidget(_mainScreen(_TestReportAppProvider(users)));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    final originalElements = find.byType(UserCard).evaluate().toSet();
    expect(originalElements, isNotEmpty);
    final rebuiltProfiles = <String>{};
    final previousCallback = debugOnRebuildDirtyWidget;
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      previousCallback?.call(element, builtOnce);
      if (builtOnce && originalElements.contains(element)) {
        rebuiltProfiles.add((element.widget as UserCard).user.username);
      }
    };
    try {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -60));
      await tester.pumpAndSettle();
      expect(rebuiltProfiles, isEmpty);
      expect(tester.takeException(), isNull);
    } finally {
      debugOnRebuildDirtyWidget = previousCallback;
    }
  });

  testWidgets('Scrolling a large report only reads nearby profiles', (
    tester,
  ) async {
    final users = _CountingUserList(
      List.generate(
        10000,
        (index) => InstagramUser(username: 'profile_$index', timestamp: index),
      ),
    );
    await tester.pumpWidget(_mainScreen(_TestReportAppProvider(users)));
    await tester.pump();
    users.reads = 0;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(users.reads, greaterThan(0));
    expect(users.reads, lessThan(1000));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Loaded report with ad slots builds valid slivers', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'ads_enabled': true});
    AdsService.instance.adsEnabled.value = true;
    final users = List.generate(
      1200,
      (index) => InstagramUser(username: 'profile_$index', timestamp: index),
    );
    await tester.pumpWidget(_mainScreen(_TestReportAppProvider(users)));
    await tester.pump();

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('feed-native-ad-0')),
      200,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(find.byType(NativeAdCard), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ad has equal visible gaps to the surrounding profile cards', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'ads_enabled': true});
    AdsService.instance.adsEnabled.value = true;
    final ads = AdsService.instance;
    final previousConsent = ads.canRequestAds.value;
    ads.canRequestAds.value = true;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      instanceManager.channel,
      (call) async => call.method == 'MobileAds#initialize'
          ? InitializationStatus({})
          : null,
    );
    addTearDown(() {
      ads.canRequestAds.value = previousConsent;
      messenger.setMockMethodCallHandler(instanceManager.channel, null);
    });
    final users = List.generate(
      100,
      (index) => InstagramUser(username: 'profile_$index', timestamp: index),
    );
    await tester.pumpWidget(_mainScreen(_TestReportAppProvider(users)));
    await tester.pump();
    final scrollable = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('feed-native-ad-0')),
      200,
      scrollable: scrollable,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 200));
    await tester.pump();

    final adFrame = find.descendant(
      of: find.byType(NativeAdCard).first,
      matching: find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.minHeight == 112,
      ),
    );
    final adRect = tester.getRect(adFrame);
    final profileRects = find
        .descendant(of: find.byType(UserCard), matching: find.byType(Material))
        .evaluate()
        .where(
          (element) => (element.widget as Material).type == MaterialType.card,
        )
        .map((element) => tester.getRect(find.byWidget(element.widget)))
        .toList();
    final above = profileRects
        .where((rect) => rect.bottom <= adRect.top)
        .map((rect) => rect.bottom)
        .reduce((a, b) => a > b ? a : b);
    final below = profileRects
        .where((rect) => rect.top >= adRect.bottom)
        .map((rect) => rect.top)
        .reduce((a, b) => a < b ? a : b);
    expect(adRect.top - above, closeTo(below - adRect.bottom, 0.01));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('Report counter changes to completed state only at zero', (
    tester,
  ) async {
    for (final count in [1, 0, 2]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsCounter(count: count, zeroCountLabel: 'Tutto a posto!'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Tutto a posto!'),
        count == 0 ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Da controllare:'),
        count == 0 ? findsNothing : findsOneWidget,
      );
      expect(find.text('$count'), count == 0 ? findsNothing : findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatsCounter(
            count: 0,
            label: 'Profili in whitelist:',
            indicatorIcon: Icons.favorite,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Profili in whitelist:'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Tutto a posto!'), findsNothing);
  });

  testWidgets('Report counter color reflects profile count thresholds', (
    tester,
  ) async {
    const colorCases = {
      9: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
      10: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      50: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      51: [Color(0xFFC62828), Color(0xFFEF5350)],
    };

    for (final entry in colorCases.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsCounter(count: entry.key)),
        ),
      );
      await tester.pump();

      final gradientBox = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).gradient is LinearGradient,
        ),
      );
      final gradient =
          (gradientBox.decoration! as BoxDecoration).gradient!
              as LinearGradient;
      expect(gradient.begin, Alignment.centerLeft);
      expect(gradient.end, Alignment.centerRight);
      expect(gradient.colors, entry.value, reason: 'count ${entry.key}');
    }
  });

  testWidgets('Report counter shows a check only when the count is zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatsCounter(count: 0))),
    );

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.priority_high_rounded), findsNothing);

    for (final count in [1, 9, 10, 51]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsCounter(count: count)),
        ),
      );
      expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    }
    final badgeCircles = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
    );
    expect(badgeCircles, findsNWidgets(2));
    expect(tester.getSize(badgeCircles.at(0)), const Size(44, 44));
    expect(tester.getSize(badgeCircles.at(1)), const Size(34, 34));
    final icon = tester.widget<Icon>(find.byIcon(Icons.priority_high_rounded));
    expect(icon.size, 18);
  });

  testWidgets('Profile cards have raised styling and blue glowing avatars', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.samsungLightTheme,
        home: Scaffold(
          body: UserCard(
            user: InstagramUser(username: 'example', timestamp: 0),
            isViewed: false,
            onTap: () async {},
            onWhitelist: () {},
          ),
        ),
      ),
    );

    final card = tester.widget<Card>(find.byType(Card));
    final shape = card.shape! as RoundedRectangleBorder;
    expect(shape.side.width, 1.5);
    expect(
      shape.side.color,
      AppTheme.samsungLightTheme.colorScheme.outlineVariant,
    );
    expect(card.elevation, 3);

    const avatarBlues = [
      Color(0xFF1565C0),
      Color(0xFF1976D2),
      Color(0xFF1E88E5),
      Color(0xFF0288D1),
      Color(0xFF039BE5),
      Color(0xFF3949AB),
      Color(0xFF3F51B5),
      Color(0xFF00838F),
    ];
    final blueAvatar = find.byWidgetPredicate(
      (widget) =>
          widget is AnimatedContainer &&
          widget.decoration is BoxDecoration &&
          avatarBlues.contains((widget.decoration! as BoxDecoration).color),
    );
    expect(blueAvatar, findsOneWidget);
    final avatarColor =
        (tester.widget<AnimatedContainer>(blueAvatar).decoration!
                as BoxDecoration)
            .color!;

    final avatarGlow = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).boxShadow?.isNotEmpty == true,
      ),
    );
    final glowDecoration = avatarGlow.decoration! as BoxDecoration;
    expect(glowDecoration.boxShadow, isNotEmpty);
    expect(
      glowDecoration.boxShadow!.first.color,
      avatarColor.withValues(alpha: 0.32),
    );
    expect(glowDecoration.boxShadow!.first.blurRadius, 12);
  });

  testWidgets('Legacy default theme migrates to Samsung One UI', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 0});
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      _mainScreen(_TestAppProvider(), themeProvider: themeProvider),
    );
    await tester.pumpAndSettle();

    expect(themeProvider.themeStyle, AppThemeStyle.samsungOneUi);
    expect(themeProvider.brightnessMode, AppBrightnessMode.system);
  });

  testWidgets('Viewed profile avatar has a ring matching its button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.samsungLightTheme,
        home: Scaffold(
          body: UserCard(
            user: InstagramUser(username: 'checked_profile', timestamp: 0),
            isViewed: true,
            onTap: () async {},
            onWhitelist: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    final viewedAvatarGradients = find.byWidgetPredicate(
      (widget) =>
          widget is AnimatedContainer &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
          (widget.decoration! as BoxDecoration).gradient ==
              AppTheme.instagramGradient,
    );
    expect(viewedAvatarGradients, findsNWidgets(2));
    final avatarLayers = tester.widgetList<AnimatedContainer>(
      viewedAvatarGradients,
    );
    expect(
      avatarLayers.map((layer) => layer.padding),
      contains(const EdgeInsets.all(3)),
    );
    final gradientPhoto = find.byWidgetPredicate(
      (widget) =>
          widget is AnimatedContainer &&
          widget.padding == null &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
          (widget.decoration! as BoxDecoration).gradient ==
              AppTheme.instagramGradient,
    );
    expect(tester.getSize(gradientPhoto), const Size(56, 56));

    final avatarGlow = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).boxShadow?.isNotEmpty == true,
      ),
    );
    final glowShadows = (avatarGlow.decoration! as BoxDecoration).boxShadow!;
    expect(glowShadows, hasLength(1));
    expect(
      glowShadows.map((shadow) => shadow.color),
      contains(AppTheme.instagramGradientMid.withValues(alpha: 0.32)),
    );
    expect(glowShadows.first.blurRadius, 12);
  });

  testWidgets('Profile card lays out avatar, details, and full-width actions', (
    tester,
  ) async {
    var opened = false;
    var whitelisted = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.samsungLightTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              height: 190,
              child: UserCard(
                user: InstagramUser(
                  username: 'profile_name',
                  timestamp: 1704110400,
                ),
                isViewed: true,
                onTap: () async => opened = true,
                onWhitelist: () => whitelisted = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('@profile_name'), findsOneWidget);
    expect(find.text('01/01/2024'), findsOneWidget);
    expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    expect(find.text('Apri'), findsNothing);
    expect(find.text('Whitelist'), findsOneWidget);
    expect(find.text('Salva in Whitelist'), findsNothing);
    expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);

    final avatar = tester.getRect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer &&
            widget.padding == null &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
      ),
    );
    final username = tester.getRect(find.text('@profile_name'));
    expect(avatar.left, lessThan(username.left));
    expect(avatar.center.dy, closeTo(username.center.dy, 40));

    final openButtonFinder = find
        .ancestor(
          of: find.byIcon(Icons.open_in_new_rounded),
          matching: find.byType(AnimatedContainer),
        )
        .first;
    final openButton = tester.widget<AnimatedContainer>(openButtonFinder);
    final openDecoration = openButton.decoration! as BoxDecoration;
    expect(openDecoration.gradient, AppTheme.instagramGradient);
    expect(openDecoration.border!.top.color, const Color(0xFF666666));
    final openButtonSize = tester.getSize(openButtonFinder);
    expect(openButtonSize.width, 50);
    expect(openButtonSize.height, 50);

    final whitelistButton = tester.widget<OutlinedButton>(
      find
          .ancestor(
            of: find.text('Whitelist'),
            matching: find.byType(OutlinedButton),
          )
          .first,
    );
    expect(
      whitelistButton.style!.backgroundColor!.resolve({}),
      const Color(0xFF2B2B2B),
    );
    expect(
      whitelistButton.style!.side!.resolve({})!.color,
      const Color(0xFF666666),
    );
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      greaterThanOrEqualTo(50),
    );
    final separator = tester.getRect(find.byType(Divider));
    final whitelistRect = tester.getRect(find.text('Whitelist'));
    expect(separator.bottom, lessThan(whitelistRect.top));

    await tester.tap(find.byIcon(Icons.open_in_new_rounded));
    await tester.pump();
    await tester.tap(find.text('Whitelist'));
    await tester.pump();
    expect(opened, isTrue);
    expect(whitelisted, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile avatar and username open the Instagram profile', (
    tester,
  ) async {
    var openCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.samsungLightTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              height: 190,
              child: UserCard(
                user: InstagramUser(username: 'profile_name', timestamp: 0),
                isViewed: false,
                onTap: () async => openCount++,
                onWhitelist: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('@profile_name'));
    await tester.pump();
    expect(openCount, 1);

    final avatar = find.byWidgetPredicate(
      (widget) =>
          widget is AnimatedContainer &&
          widget.padding == null &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
    );
    await tester.tap(avatar);
    await tester.pump();
    expect(openCount, 2);
  });

  testWidgets('Main title icon follows app brightness, not icon preference', (
    tester,
  ) async {
    const appIconChannel = MethodChannel(
      'com.simpledevperson.instalander/app_icon',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(appIconChannel, (_) async => null);
    addTearDown(() => messenger.setMockMethodCallHandler(appIconChannel, null));
    final themeProvider = ThemeProvider();
    final appProvider = _TestAppProvider();

    Widget buildApp(ThemeMode mode) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<AppProvider>.value(value: appProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.samsungLightTheme,
        darkTheme: AppTheme.samsungDarkTheme,
        themeMode: mode,
        home: const MainScreen(),
      ),
    );

    await themeProvider.setAppIconStyle(AppIconStyle.dark);
    await tester.pumpWidget(buildApp(ThemeMode.light));
    await tester.pumpAndSettle();

    Image appIcon = tester.widget<Image>(find.byType(Image).first);
    expect(
      (appIcon.image as AssetImage).assetName,
      'assets/images/app_icon_original.png',
    );
    expect(appIcon.width, 44);
    expect(appIcon.height, 44);
    final header = tester.widget<Container>(
      find.byKey(const Key('main-title-header')),
    );
    expect((header.padding as EdgeInsets).top, 28);

    await tester.pumpWidget(buildApp(ThemeMode.dark));
    await tester.pumpAndSettle();

    appIcon = tester.widget<Image>(find.byType(Image).first);
    expect(
      (appIcon.image as AssetImage).assetName,
      'assets/images/app_icon_dark.jpg',
    );
  });

  testWidgets('Holding a profile card expands its details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.samsungLightTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              height: 190,
              child: UserCard(
                user: InstagramUser(
                  username: 'profile_name',
                  timestamp: 1704110400,
                ),
                isViewed: false,
                onTap: () async {},
                onWhitelist: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('@profile_name')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Dettagli del profilo'), findsOneWidget);
    expect(find.textContaining('01/01/2024 •'), findsOneWidget);
    expect(find.text('Non ti segue'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    final actionButton = find
        .ancestor(
          of: find.text('Instagram'),
          matching: find.byType(AnimatedContainer),
        )
        .first;
    expect(tester.getSize(actionButton).height, greaterThanOrEqualTo(52));
    final expandedPositions = tester.widgetList<AnimatedPositioned>(
      find.byType(AnimatedPositioned),
    );
    expect(expandedPositions.map((position) => position.height), contains(420));
    expect(expandedPositions.map((position) => position.height), contains(68));
    final expandedCard = tester.widget<Material>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Material &&
            widget.shape is RoundedRectangleBorder &&
            (widget.shape! as RoundedRectangleBorder).side.width == 1.5 &&
            (widget.shape! as RoundedRectangleBorder).side.color ==
                AppTheme.samsungLightTheme.colorScheme.outline,
      ),
    );
    expect(expandedCard.shape, isA<RoundedRectangleBorder>());
    expect(tester.takeException(), isNull);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Dettagli del profilo'), findsNothing);
  });

  testWidgets('Dragging from a held profile selects an action below it', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.samsungLightTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              height: 190,
              child: UserCard(
                user: InstagramUser(username: 'profile_name', timestamp: 0),
                isViewed: false,
                onTap: () async => opened = true,
                onWhitelist: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('@profile_name')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 250));
    final instagramAction = find.text('Instagram');
    expect(instagramAction, findsOneWidget);

    await gesture.moveTo(tester.getCenter(instagramAction));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    expect(find.text('Dettagli del profilo'), findsNothing);
  });

  testWidgets('Settings show both app icon previews', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.ensureVisible(find.text('Icona chiara'));
    await tester.pumpAndSettle();

    final settingsScaffold = tester.widget<Scaffold>(
      find.ancestor(
        of: find.text('Impostazioni'),
        matching: find.byType(Scaffold),
      ),
    );
    expect(settingsScaffold.appBar, isNull);
    expect(
      settingsScaffold.backgroundColor,
      AppTheme.getBgColor(tester.element(find.text('Impostazioni'))),
    );
    final settingsTitle = tester.widget<Text>(find.text('Impostazioni'));
    expect(settingsTitle.textAlign, TextAlign.center);
    expect(settingsTitle.style?.fontSize, 36);
    expect(settingsTitle.style?.fontWeight, FontWeight.w700);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    expect(find.text('Icona scura'), findsOneWidget);
    expect(find.text('Icona originale con sfondo chiaro'), findsOneWidget);
    expect(find.text('Variante con sfondo scuro'), findsOneWidget);
    final previewAssets = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName)
        .toSet();
    expect(
      previewAssets,
      containsAll({
        'assets/images/app_icon_original.png',
        'assets/images/app_icon_dark.jpg',
      }),
    );
    final previewClips = tester
        .widgetList<ClipRRect>(find.byType(ClipRRect))
        .toList();
    expect(previewClips, hasLength(2));
    expect(
      previewClips.map((clip) => clip.borderRadius),
      everyElement(BorderRadius.circular(14)),
    );
    final previewImages = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(previewImages, hasLength(2));
    expect(previewImages.map((image) => image.width), everyElement(53));
    expect(previewImages.map((image) => image.height), everyElement(53));
    final previewContainers = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (container) =>
              container.constraints?.maxWidth == 56 &&
              container.constraints?.maxHeight == 56,
        )
        .toList();
    expect(previewContainers, hasLength(2));
    expect(
      previewContainers.map(
        (container) => (container.decoration! as BoxDecoration).border,
      ),
      everyElement(isNotNull),
    );
  });

  testWidgets('Whitelist switches between list and bordered profile grid', (
    tester,
  ) async {
    final provider = _TestWhitelistAppProvider({'first_profile', 'second'});
    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(home: WhitelistScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Whitelist'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Whitelist'));
    expect(title.textAlign, TextAlign.center);
    expect(title.style?.fontSize, 36);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(find.byIcon(Icons.favorite), findsAtLeastNWidgets(2));
    expect(find.text('Profili in whitelist:'), findsOneWidget);
    expect(find.text('Più recenti'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, '@second');
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    expect(find.text('first_profile'), findsNothing);
    await tester.tap(find.byTooltip('Cancella ricerca'));
    await tester.pumpAndSettle();
    expect(find.text('first_profile'), findsOneWidget);
    _expectWhitelistAvatarGlow(tester, 'first_profile');
    final theme = Theme.of(tester.element(find.byType(WhitelistScreen)));
    final listCard = tester.widget<Card>(
      find.ancestor(
        of: find.byKey(const ValueKey('whitelist-avatar-first_profile')),
        matching: find.byType(Card),
      ),
    );
    expect(listCard.color, theme.cardTheme.color);
    final clearButtonFrame = tester.widget<Container>(
      find.byKey(const Key('clear-whitelist-button-frame')),
    );
    final clearButtonBorder =
        (clearButtonFrame.decoration! as BoxDecoration).border! as Border;
    final errorColor = Theme.of(
      tester.element(find.byType(WhitelistScreen)),
    ).colorScheme.error;
    expect(clearButtonBorder.top.color, errorColor);
    expect(
      tester
          .getTopLeft(find.byKey(const Key('clear-whitelist-button-frame')))
          .dx,
      greaterThan(
        tester.getTopLeft(find.byType(PopupMenuButton<SortOption>)).dx,
      ),
    );

    await tester.tap(find.text('Griglia'));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('@first_profile'), findsOneWidget);
    expect(find.text('@second'), findsOneWidget);
    _expectWhitelistAvatarGlow(tester, 'first_profile');
    final profileCards = tester.widgetList<Card>(find.byType(Card)).toList();
    expect(profileCards, hasLength(2));
    for (final card in profileCards) {
      expect(card.color, theme.cardTheme.color);
      final shape = card.shape! as RoundedRectangleBorder;
      expect(shape.side.width, 1.5);
      expect(
        shape.side.color,
        Theme.of(
          tester.element(find.byType(WhitelistScreen)),
        ).colorScheme.outlineVariant,
      );
    }

    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);

    await tester.tap(find.text('Più recenti'));
    await tester.pumpAndSettle();
    expect(find.text('Data decrescente'), findsOneWidget);
    expect(find.text('(Più recenti prima)'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_outlined), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_downward), findsNWidgets(2));
    expect(find.text('A\nZ'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.text('Alfabetico (A-Z)'));
    await tester.pumpAndSettle();
    expect(find.text('Nome A-Z'), findsOneWidget);
    expect(find.text('Profili in whitelist:'), findsOneWidget);

    await tester.tap(find.byTooltip('Svuota whitelist'));
    await tester.pumpAndSettle();
    expect(find.text('Svuota whitelist'), findsOneWidget);
    expect(
      _contrastRatio(
        Theme.of(
          tester.element(find.text('Svuota whitelist')),
        ).colorScheme.onSurface,
        Theme.of(
          tester.element(find.text('Svuota whitelist')),
        ).colorScheme.surfaceContainerHigh,
      ),
      greaterThanOrEqualTo(4.5),
    );
    final clearDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(
      _contrastRatio(
        clearDialog.titleTextStyle!.color!,
        clearDialog.backgroundColor!,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(
        clearDialog.contentTextStyle!.color!,
        clearDialog.backgroundColor!,
      ),
      greaterThanOrEqualTo(4.5),
    );
    final cancelButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Annulla'),
    );
    final submitButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Svuota tutto'),
    );
    expect(
      _contrastRatio(
        cancelButton.style!.foregroundColor!.resolve({})!,
        clearDialog.backgroundColor!,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(
        submitButton.style!.foregroundColor!.resolve({})!,
        submitButton.style!.backgroundColor!.resolve({})!,
      ),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('Settings confirms before clearing all app data', (tester) async {
    final appProvider = _ClearableTestAppProvider();
    await appProvider.enableDebugTools();
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: appProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Cancella tutti i dati'), 250);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancella tutti i dati'));
    await tester.pumpAndSettle();
    expect(find.text('Cancellare tutti i dati?'), findsOneWidget);
    final resetCard = tester.widget<Card>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Card &&
            widget.shape is RoundedRectangleBorder &&
            ((widget.shape! as RoundedRectangleBorder).side.width == 1.5),
      ),
    );
    final resetBorder = resetCard.shape! as RoundedRectangleBorder;
    expect(
      resetBorder.side.color,
      Theme.of(
        tester.element(find.byType(SettingsScreen)),
      ).colorScheme.error.withValues(alpha: 0.55),
    );
    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Cancella tutto'),
    );
    expect(
      _contrastRatio(
        confirmButton.style!.foregroundColor!.resolve({})!,
        confirmButton.style!.backgroundColor!.resolve({})!,
      ),
      greaterThanOrEqualTo(4.5),
    );

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(appProvider.clearCount, 0);

    await tester.tap(find.text('Cancella tutti i dati'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancella tutto'));
    await tester.pumpAndSettle();

    expect(appProvider.clearCount, 1);
    expect(themeProvider.themeStyle, AppThemeStyle.samsungOneUi);
    expect(themeProvider.brightnessMode, AppBrightnessMode.system);
  });
}

void _expectWhitelistAvatarGlow(WidgetTester tester, String username) {
  final avatarContainer = tester.widget<Container>(
    find.byKey(ValueKey('whitelist-avatar-$username')),
  );
  final decoration = avatarContainer.decoration! as BoxDecoration;
  expect(decoration.shape, BoxShape.circle);
  expect(decoration.boxShadow, hasLength(1));
  expect(decoration.boxShadow!.single.blurRadius, 12);
  expect(decoration.boxShadow!.single.spreadRadius, 1);

  final avatar = avatarContainer.child! as CircleAvatar;
  expect(
    decoration.boxShadow!.single.color,
    avatar.backgroundColor!.withValues(alpha: 0.32),
  );
}

Widget _mainScreen(
  _TestAppProvider appProvider, {
  ThemeProvider? themeProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider ?? ThemeProvider(),
      ),
      ChangeNotifierProvider<AppProvider>.value(value: appProvider),
    ],
    child: const MaterialApp(home: MainScreen()),
  );
}

class _CountingUserList extends ListBase<InstagramUser> {
  _CountingUserList(this.data);
  final List<InstagramUser> data;
  int reads = 0;

  @override
  int get length => data.length;
  @override
  set length(int value) => throw UnsupportedError('Fixed length');
  @override
  InstagramUser operator [](int index) {
    reads++;
    return data[index];
  }

  @override
  void operator []=(int index, InstagramUser value) => data[index] = value;
}

class _TestAppProvider extends AppProvider {
  final bool _hasFollowersFile;
  final bool _hasFollowingFile;
  final bool _hasData;

  _TestAppProvider({
    bool hasFollowersFile = false,
    bool hasFollowingFile = false,
    bool hasData = false,
  }) : _hasFollowersFile = hasFollowersFile,
       _hasFollowingFile = hasFollowingFile,
       _hasData = hasData;

  @override
  bool get isLoading => false;

  @override
  bool get hasData => _hasData;

  @override
  bool get hasFollowersFile => _hasFollowersFile;

  @override
  bool get hasFollowingFile => _hasFollowingFile;

  @override
  bool get hasPartialData => _hasFollowersFile != _hasFollowingFile;

  @override
  bool get shouldShowOnboarding => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> initialize() async {}
}

class _RestartableOnboardingProvider extends _TestAppProvider {
  bool _showOnboarding = false;

  @override
  bool get shouldShowOnboarding => _showOnboarding;

  @override
  Future<void> clearAllData() async {
    _showOnboarding = true;
    notifyListeners();
  }

  @override
  Future<void> completeOnboarding() async {
    await super.completeOnboarding();
    _showOnboarding = false;
    notifyListeners();
  }
}

class _ClearableTestAppProvider extends _TestAppProvider {
  int clearCount = 0;

  @override
  Future<void> clearAllData() async {
    clearCount++;
  }
}

class _TestReportAppProvider extends _TestAppProvider {
  final List<InstagramUser> users;

  _TestReportAppProvider(this.users)
    : super(hasData: true, hasFollowersFile: true, hasFollowingFile: true);

  @override
  List<InstagramUser> get sortedNonFollowers => users;
}

class _TestWhitelistAppProvider extends _TestAppProvider {
  final Set<String> entries;

  _TestWhitelistAppProvider(this.entries);

  @override
  Set<String> get whitelist => entries;

  @override
  void removeFromWhitelist(String username) {
    entries.remove(username);
    notifyListeners();
  }
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
