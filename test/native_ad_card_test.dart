import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// Use the plugin's channel to retain its custom message codec in the mock.
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/settings_screen.dart';
import 'package:instalander/services/ads_service.dart';
import 'package:instalander/widgets/native_ad_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdsService.instance.adsEnabled.value = true;
  });

  test(
    'ads default to disabled and preserve an explicit saved choice',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final ads = AdsService.instance;
      await ads.initialize();
      expect(ads.adsEnabled.value, isFalse);
      await ads.setAdsEnabled(true);
      ads.adsEnabled.value = false;
      await ads.initialize();
      expect(ads.adsEnabled.value, isTrue);
    },
  );

  testWidgets(
    'Advertising settings are hidden without changing saved preferences',
    (tester) async {
      SharedPreferences.setMockInitialValues({'ads_enabled': true});
      final ads = AdsService.instance;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 12; i++) {
        expect(find.text('Pubblicità'), findsNothing);
        expect(find.text('Mostra annunci'), findsNothing);
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pumpAndSettle();
      }
      expect(ads.adsEnabled.value, isTrue);
      expect(
        (await SharedPreferences.getInstance()).getBool('ads_enabled'),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  for (final consentInitiallyAvailable in [true, false]) {
    testWidgets('Native ad loads once with consent available '
        '${consentInitiallyAvailable ? 'before mount' : 'after mount'}', (
      tester,
    ) async {
      final consent = AdsService.instance.canRequestAds;
      final previousConsent = consent.value;
      consent.value = consentInitiallyAvailable;
      final calls = <MethodCall>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(instanceManager.channel, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(instanceManager.channel, null);
        consent.value = previousConsent;
      });

      Widget buildApp(Brightness brightness) => MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const Scaffold(body: NativeAdCard()),
      );

      int loadCount() =>
          calls.where((call) => call.method == 'loadNativeAd').length;

      await tester.pumpWidget(buildApp(Brightness.light));
      expect(tester.takeException(), isNull);
      expect(loadCount(), consentInitiallyAvailable ? 1 : 0);

      if (!consentInitiallyAvailable) {
        consent.value = true;
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      expect(loadCount(), 1);

      await tester.pumpWidget(buildApp(Brightness.dark));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(loadCount(), 1);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(calls.where((call) => call.method == 'disposeAd'), hasLength(1));
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
}
