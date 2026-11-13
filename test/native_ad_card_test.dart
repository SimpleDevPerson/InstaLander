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

  testWidgets('Settings persist and restore the ads switch', (tester) async {
    final ads = AdsService.instance;
    addTearDown(() => ads.adsEnabled.value = true);
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
    await tester.scrollUntilVisible(find.text('Mostra annunci'), 250);
    await tester.pumpAndSettle();
    final adsCard = find.ancestor(
      of: find.text('Mostra annunci'),
      matching: find.byType(Card),
    );
    final listRect = tester.getRect(find.byType(ListView));
    final cardRect = tester.getRect(adsCard);
    expect(cardRect.left, listRect.left + 16);
    expect(cardRect.right, listRect.right - 16);
    await tester.tap(find.text('Mostra annunci'));
    await tester.pumpAndSettle();
    expect(ads.adsEnabled.value, isFalse);
    expect(
      tester
          .widget<Switch>(
            find.descendant(of: adsCard, matching: find.byType(Switch)),
          )
          .value,
      isFalse,
    );

    ads.adsEnabled.value = true;
    await ads.initialize();
    await tester.pumpAndSettle();
    expect(ads.adsEnabled.value, isFalse);

    await tester.tap(find.text('Mostra annunci'));
    await tester.pumpAndSettle();
    expect(ads.adsEnabled.value, isTrue);
    expect(
      (await SharedPreferences.getInstance()).getBool('ads_enabled'),
      isTrue,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

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
