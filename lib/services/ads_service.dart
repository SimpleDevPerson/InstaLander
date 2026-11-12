import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
const _configuredNativeAdUnitId = String.fromEnvironment(
  'ADMOB_NATIVE_AD_UNIT_ID',
);

class AdsService {
  AdsService._();

  static final AdsService instance = AdsService._();
  static const _adsEnabledKey = 'ads_enabled';

  final ValueNotifier<bool> adsEnabled = ValueNotifier(true);
  final ValueNotifier<bool> canRequestAds = ValueNotifier(false);
  final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier(false);
  Future<void>? _initialization;

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get nativeAdUnitId {
    if (_configuredNativeAdUnitId.isNotEmpty) {
      return _configuredNativeAdUnitId;
    }
    return kDebugMode ? _testNativeAdUnitId : '';
  }

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    adsEnabled.value = preferences.getBool(_adsEnabledKey) ?? true;
    if (adsEnabled.value) await _initializeSdk();
  }

  Future<void> setAdsEnabled(bool enabled) async {
    adsEnabled.value = enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_adsEnabledKey, enabled);
    if (enabled) await _initializeSdk();
  }

  Future<void> _initializeSdk() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (!isSupportedPlatform) return;

    try {
      await MobileAds.instance.initialize();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => unawaited(_showRequiredConsentForm()),
        (error) {
          debugPrint('Aggiornamento consenso AdMob non riuscito: $error');
          unawaited(_refreshConsentStatus());
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Inizializzazione AdMob non riuscita: $error\n$stackTrace');
    }
  }

  Future<void> _showRequiredConsentForm() async {
    try {
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) {
          debugPrint('Modulo consenso AdMob non riuscito: $error');
        }
      });
      await _refreshConsentStatus();
    } catch (error, stackTrace) {
      debugPrint(
          'Caricamento consenso AdMob non riuscito: $error\n$stackTrace');
    }
  }

  Future<void> _refreshConsentStatus() async {
    try {
      final canRequest = await ConsentInformation.instance.canRequestAds();
      final privacyStatus = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      canRequestAds.value = canRequest;
      privacyOptionsRequired.value =
          privacyStatus == PrivacyOptionsRequirementStatus.required;
    } catch (error, stackTrace) {
      debugPrint(
          'Lettura del consenso AdMob non riuscita: $error\n$stackTrace');
    }
  }

  Future<void> showPrivacyOptions() async {
    if (!isSupportedPlatform || !privacyOptionsRequired.value) return;

    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          debugPrint('Opzioni privacy AdMob non riuscite: $error');
        }
      });
      await _refreshConsentStatus();
    } catch (error, stackTrace) {
      debugPrint('Apertura opzioni privacy AdMob non riuscita: '
          '$error\n$stackTrace');
    }
  }
}
