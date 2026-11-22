import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'l10n/app_strings.dart';
import 'providers/app_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/whitelist_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  runApp(const InstagramFollowerCheckerApp());
}

class InstagramFollowerCheckerApp extends StatelessWidget {
  const InstagramFollowerCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isSamsung = themeProvider.isSamsungTheme;
          return MaterialApp(
            title: 'InstaLander',
            debugShowCheckedModeBanner: false,
            locale: themeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeListResolutionCallback: AppStrings.resolveLocale,
            theme: isSamsung ? AppTheme.samsungLightTheme : AppTheme.lightTheme,
            darkTheme: isSamsung
                ? AppTheme.samsungDarkTheme
                : AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: AppTheme.systemBarStyle(Theme.of(context).brightness),
              child: child!,
            ),
            home: const MainScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/whitelist': (context) => const WhitelistScreen(),
            },
          );
        },
      ),
    );
  }
}
