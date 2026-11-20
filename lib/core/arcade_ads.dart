import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// ArcadeAds manages Google Mobile Ads lifecycle, initialization,
/// and provides styled Native Ad widgets compliant with AdMob policies.
class ArcadeAds {
  ArcadeAds._();

  /// User's production AdMob App ID
  static const String admobAppId = 'ca-app-pub-5207303042046289~8266387223';

  /// User's production Native Ad Unit ID
  static const String liveNativeAdUnitId = 'ca-app-pub-5207303042046289/9384027774';

  /// Official Google Sample/Test Native Ad Unit IDs
  static const String testAndroidNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
  static const String testIOSNativeAdUnitId = 'ca-app-pub-3940256099942544/3986624511';

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Returns true only on supported mobile platforms (Android & iOS).
  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Automatically uses Google test ad units in debug mode to protect
  /// against invalid traffic policy strikes, and uses the real ad unit in release.
  static String get nativeAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? testAndroidNativeAdUnitId
          : testIOSNativeAdUnitId;
    }
    return liveNativeAdUnitId;
  }

  /// Initializes the Google Mobile Ads SDK safely.
  static Future<void> initialize() async {
    if (!isSupportedPlatform || _initialized) return;

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('ArcadeAds: Google Mobile Ads SDK initialized successfully.');
    } catch (e, st) {
      debugPrint('ArcadeAds: Mobile Ads initialization skipped or failed: $e\n$st');
    }
  }
}

/// A sleek, cyber-arcade styled Native Ad card widget.
///
/// If the ad is loading, fails to load, or is on an unsupported platform (e.g. desktop/web),
/// it gracefully collapses without taking up empty screen space.
class ArcadeNativeAdCard extends StatefulWidget {
  const ArcadeNativeAdCard({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  State<ArcadeNativeAdCard> createState() => _ArcadeNativeAdCardState();
}

class _ArcadeNativeAdCardState extends State<ArcadeNativeAdCard> {
  NativeAd? _nativeAd;
  bool _adLoaded = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!ArcadeAds.isSupportedPlatform) return;

    final adUnitId = ArcadeAds.nativeAdUnitId;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _adLoaded = true;
            _loadFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('ArcadeAds: Native ad failed to load ($adUnitId): ${error.message} (code ${error.code})');
          ad.dispose();
          if (mounted) {
            setState(() {
              _nativeAd = null;
              _adLoaded = false;
              _loadFailed = true;
            });
          }
        },
        onAdOpened: (ad) => debugPrint('ArcadeAds: Ad opened.'),
        onAdClosed: (ad) => debugPrint('ArcadeAds: Ad closed.'),
        onAdImpression: (ad) => debugPrint('ArcadeAds: Ad recorded impression.'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: const Color(0xFF0A111B),
        cornerRadius: 8.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF02060B),
          backgroundColor: const Color(0xFF48F2C1),
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFFE6EDF3),
          size: 14.0,
          style: NativeTemplateFontStyle.bold,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF8B949E),
          size: 12.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF485A6A),
          size: 11.0,
        ),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ArcadeAds.isSupportedPlatform || _loadFailed || !_adLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A111B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF48F2C1).withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF48F2C1).withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cyberpunk arcade transmission header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: const Color(0xFF0F1A26),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF48F2C1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'COMMERCIAL TRANSMISSION',
                  style: TextStyle(
                    color: Color(0xFF75DFFF),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 90,
              maxHeight: 105,
            ),
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }
}
