import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// Loads and shows interstitial ads with a frequency cap.
///
/// Call [registerAction] on each qualifying user action (e.g. finishing a
/// calculation); roughly every [AdsConfig.interstitialEveryNActions] actions it
/// shows a preloaded interstitial. Interstitials are NEVER shown before a result
/// — only on natural break points — to keep the experience respectful.
class InterstitialAdManager {
  InterstitialAdManager._();

  static final InterstitialAdManager instance = InterstitialAdManager._();

  InterstitialAd? _ad;
  bool _loading = false;
  int _actionCount = 0;

  void preload() {
    if (_ad != null || _loading) {
      return;
    }
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdsConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  /// Records an action and shows an interstitial when the cap is reached.
  /// [adsEnabled] lets the caller respect the ads-removed flag.
  void registerAction({required bool adsEnabled}) {
    if (!adsEnabled) {
      return;
    }
    _actionCount++;
    if (_actionCount % AdsConfig.interstitialEveryNActions == 0) {
      _show();
    } else {
      preload();
    }
  }

  void _show() {
    final ad = _ad;
    if (ad == null) {
      preload();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _ad = null;
        preload();
      },
    );
    ad.show();
    _ad = null;
  }
}
