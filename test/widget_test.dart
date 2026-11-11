import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/main.dart';
import 'package:instalander/models/user.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/main_screen.dart';
import 'package:instalander/screens/onboarding_screen.dart';
import 'package:instalander/screens/settings_screen.dart';
import 'package:instalander/theme/app_theme.dart';
import 'package:instalander/widgets/stats_counter.dart';
import 'package:instalander/widgets/user_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
        home: OnboardingScreen(
          onComplete: () async => completed = true,
        ),
      ),
    );

    expect(
      find.text('Apri il Centro gestione account').hitTestable(),
      findsOneWidget,
    );
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(
      find.text('Richiedi una copia dei dati').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text('Avanti').hitTestable());
    await tester.pumpAndSettle();
    expect(
      find.text('Scegli il formato JSON').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text('Avanti').hitTestable());
    await tester.pumpAndSettle();
    expect(
      find.text('Scarica ed estrai l’archivio').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text("Procedi nell'app").hitTestable());
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });

  testWidgets('Onboarding button labels meet contrast on every theme',
      (tester) async {
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

  testWidgets('Setup hides the report count before files are loaded',
      (tester) async {
    await tester.pumpWidget(_mainScreen(_TestAppProvider()));
    await tester.pump();

    expect(find.text('Instalander'), findsOneWidget);
    final header = find.ancestor(
      of: find.text('Instalander'),
      matching: find.byType(Container),
    );
    expect(tester.widget<Container>(header.first).decoration, isNull);
    expect(find.descendant(of: header.first, matching: find.byType(Stack)),
        findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Instalander')).style?.fontSize,
      34,
    );
    expect(find.byType(StatsCounter), findsNothing);
    expect(find.text('Da controllare: '), findsNothing);
    expect(find.textContaining('Puoi scaricarli da Instagram'), findsNothing);
    expect(
      find.text('Come scaricare i file da Instagram'),
      findsOneWidget,
    );
    expect(find.text('followers_*.json'), findsOneWidget);
    expect(find.text('following_*.json'), findsOneWidget);
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

  testWidgets('Back from a secondary tab returns to the report',
      (tester) async {
    await tester.pumpWidget(_mainScreen(_TestAppProvider()));
    await tester.pump();

    final pageSwipeDistance =
        tester.view.physicalSize.width / tester.view.devicePixelRatio * 0.8;
    await tester.drag(
      find.byType(PageView),
      Offset(-pageSwipeDistance, 0),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(PageView),
      Offset(-pageSwipeDistance, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni'), findsWidgets);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Instalander'), findsOneWidget);
  });

  testWidgets('Navigation skips the middle page when switching endpoints',
      (tester) async {
    await tester.pumpWidget(_mainScreen(_TestAppProvider()));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_outlined).hitTestable());
    await tester.pump();
    expect(find.text('Impostazioni').hitTestable(), findsOneWidget);
    expect(find.text('Whitelist').hitTestable(), findsNothing);

    await tester.tap(find.byIcon(Icons.analytics_outlined).hitTestable());
    await tester.pump();
    expect(find.text('Instalander').hitTestable(), findsOneWidget);
    expect(find.text('Whitelist').hitTestable(), findsNothing);
  });

  testWidgets('Theme changes preserve the selected page and navbar index',
      (tester) async {
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
    await tester.drag(
      find.byType(PageView),
      Offset(-pageSwipeDistance, 0),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(PageView),
      Offset(-pageSwipeDistance, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni'), findsWidgets);

    await themeProvider.setThemeStyle(AppThemeStyle.materialExpressive);
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    expect(navigationBar, findsOneWidget);
    expect(tester.widget<NavigationBar>(navigationBar).selectedIndex, 2);
    expect(find.text('Impostazioni'), findsWidgets);
    expect(
      tester.getSize(navigationBar).width,
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
    );
    expect(find.byType(SegmentedButton<AppBrightnessMode>), findsOneWidget);
    final segmentedButton = tester.widget<SegmentedButton<AppBrightnessMode>>(
      find.byType(SegmentedButton<AppBrightnessMode>),
    );
    final selectedBackground =
        segmentedButton.style!.backgroundColor!.resolve({WidgetState.selected});
    expect(
      selectedBackground,
      Theme.of(tester.element(find.byType(MainScreen))).colorScheme.primary,
    );

    await tester.ensureVisible(find.text('Scuro'));
    await tester.tap(find.text('Scuro').hitTestable());
    await tester.pumpAndSettle();
    expect(themeProvider.brightnessMode, AppBrightnessMode.dark);
    expect(tester.widget<NavigationBar>(navigationBar).selectedIndex, 2);
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
    expect(tester.getSize(samsungNavbar).width, 220);

    await themeProvider.setBrightnessMode(AppBrightnessMode.system);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Instalander'), findsOneWidget);
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
    expect(find.text('Instalander'), findsNothing);
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

  testWidgets('Report counter color reflects profile count thresholds',
      (tester) async {
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
      final gradient = (gradientBox.decoration! as BoxDecoration).gradient!
          as LinearGradient;
      expect(gradient.begin, Alignment.centerLeft);
      expect(gradient.end, Alignment.centerRight);
      expect(gradient.colors, entry.value, reason: 'count ${entry.key}');
    }
  });

  testWidgets('Report counter shows a check when the count is green',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatsCounter(count: 9)),
      ),
    );

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.priority_high_rounded), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatsCounter(count: 10)),
      ),
    );

    expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
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

  testWidgets('Profile cards have raised styling and blue glowing avatars',
      (tester) async {
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
          avatarBlues.contains(
            (widget.decoration! as BoxDecoration).color,
          ),
    );
    expect(blueAvatar, findsOneWidget);
    final avatarColor = (tester
            .widget<AnimatedContainer>(blueAvatar)
            .decoration! as BoxDecoration)
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

  testWidgets('Legacy default theme migrates to Samsung One UI',
      (tester) async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 0});
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      _mainScreen(_TestAppProvider(), themeProvider: themeProvider),
    );
    await tester.pumpAndSettle();

    expect(themeProvider.themeStyle, AppThemeStyle.samsungOneUi);
    expect(themeProvider.brightnessMode, AppBrightnessMode.system);
  });

  testWidgets('Viewed profile avatar has a ring matching its button',
      (tester) async {
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

  testWidgets('Profile card lays out avatar, details, and full-width actions',
      (tester) async {
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
    final openButton = tester.widget<AnimatedContainer>(
      openButtonFinder,
    );
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
    expect(whitelistButton.style!.backgroundColor!.resolve({}),
        const Color(0xFF2B2B2B));
    expect(whitelistButton.style!.side!.resolve({})!.color,
        const Color(0xFF666666));
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

  testWidgets('Profile avatar and username open the Instagram profile',
      (tester) async {
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
    final expandedPositions =
        tester.widgetList<AnimatedPositioned>(find.byType(AnimatedPositioned));
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

  testWidgets('Dragging from a held profile selects an action below it',
      (tester) async {
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

  testWidgets('Settings confirms before clearing all app data', (tester) async {
    final appProvider = _ClearableTestAppProvider();
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: appProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -900));
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
      Theme.of(tester.element(find.byType(SettingsScreen)))
          .colorScheme
          .error
          .withValues(alpha: 0.55),
    );
    final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Cancella tutto'));
    expect(
      confirmButton.style!.foregroundColor!.resolve({}),
      Colors.black,
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

class _TestAppProvider extends AppProvider {
  final bool _hasFollowersFile;
  final bool _hasFollowingFile;
  final bool _hasData;

  _TestAppProvider({
    bool hasFollowersFile = false,
    bool hasFollowingFile = false,
    bool hasData = false,
  })  : _hasFollowersFile = hasFollowersFile,
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

class _ClearableTestAppProvider extends _TestAppProvider {
  int clearCount = 0;

  @override
  Future<void> clearAllData() async {
    clearCount++;
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
