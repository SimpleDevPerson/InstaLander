import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../l10n/app_strings.dart';
import '../services/ads_service.dart';

class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _ad;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AdsService.instance.canRequestAds.addListener(_onConsentChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AdsService.instance.canRequestAds.value) _loadAd();
  }

  @override
  void dispose() {
    AdsService.instance.canRequestAds.removeListener(_onConsentChanged);
    _ad?.dispose();
    super.dispose();
  }

  void _onConsentChanged() {
    if (AdsService.instance.canRequestAds.value) _loadAd();
  }

  void _loadAd() {
    final adUnitId = AdsService.nativeAdUnitId;
    if (!AdsService.isSupportedPlatform ||
        !AdsService.instance.adsEnabled.value ||
        !AdsService.instance.canRequestAds.value ||
        adUnitId.isEmpty ||
        _isLoading ||
        _ad != null) {
      return;
    }

    _isLoading = true;
    final colorScheme = Theme.of(context).colorScheme;
    final ad = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor:
            Theme.of(context).cardTheme.color ?? colorScheme.surface,
        cornerRadius: 16,
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: colorScheme.onSurface,
          style: NativeTemplateFontStyle.bold,
          size: 16,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: colorScheme.onSurfaceVariant,
          size: 13,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: colorScheme.onSurfaceVariant,
          size: 12,
        ),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          style: NativeTemplateFontStyle.bold,
          size: 13,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted) {
            loadedAd.dispose();
            return;
          }
          setState(() {
            _ad = loadedAd as NativeAd;
            _isLoaded = true;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          debugPrint('Caricamento annuncio nativo non riuscito: $error');
          failedAd.dispose();
          if (mounted) {
            setState(() {
              _ad = null;
              _isLoaded = false;
              _isLoading = false;
            });
          }
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AdsService.instance.canRequestAds,
      builder: (context, canRequestAds, child) {
        if (!AdsService.isSupportedPlatform ||
            !canRequestAds ||
            AdsService.nativeAdUnitId.isEmpty) {
          return const SizedBox.shrink();
        }

        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          // Above: 12 from UserCard + 12 from the profile row + 8 here.
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: _isLoaded && _ad != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          context.l10n.ad,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                      SizedBox(height: 96, child: AdWidget(ad: _ad!)),
                    ],
                  )
                : SizedBox(
                    height: 96,
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              context.l10n.adUnavailable,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
