import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/main.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/main_screen.dart';
import 'package:instalander/screens/onboarding_screen.dart';
import 'package:instalander/widgets/stats_counter.dart';
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

  testWidgets('Setup hides the report count before files are loaded',
      (tester) async {
    await tester.pumpWidget(_mainScreen(_TestAppProvider()));
    await tester.pump();

    expect(find.text('Instalander'), findsOneWidget);
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
