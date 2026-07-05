import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';
import 'interstitial_ad_manager.dart';

/// Loads and shows App Open ads when the app is cold-started or returns to the
/// foreground, mirroring [InterstitialAdManager]'s singleton style.
///
/// [showIfAvailable] is guarded so an App Open ad only appears when it's polite
/// and policy-compliant: never when ads are removed, never while another
/// full-screen ad (interstitial or a previous App Open) is on screen, and never
/// more than once per [AdsConfig.appOpenMinInterval].
class AppOpenAdManager {
  AppOpenAdManager._({
    DateTime Function()? now,
    bool Function()? interstitialIsShowing,
  }) : _now = now ?? DateTime.now,
       _interstitialIsShowing =
           interstitialIsShowing ??
           (() => InterstitialAdManager.instance.isShowing);

  static final AppOpenAdManager instance = AppOpenAdManager._();

  /// Builds an isolated instance with injectable collaborators for testing the
  /// guard/frequency-cap logic without touching the Ads SDK.
  @visibleForTesting
  factory AppOpenAdManager.forTest({
    DateTime Function()? now,
    bool Function()? interstitialIsShowing,
  }) => AppOpenAdManager._(now: now, interstitialIsShowing: interstitialIsShowing);

  final DateTime Function() _now;
  final bool Function() _interstitialIsShowing;

  AppOpenAd? _ad;
  bool _isLoadingAd = false;
  bool _isAdAvailable = false;
  bool _isShowingAd = false;
  DateTime? _lastShownAt;

  /// Test seam: when set, [showIfAvailable] calls this instead of presenting a
  /// real [AppOpenAd], so the decision logic can be exercised off-SDK.
  @visibleForTesting
  VoidCallback? presentOverride;

  bool get isShowing => _isShowingAd;

  void load() {
    if (_isLoadingAd || _isAdAvailable) {
      return;
    }
    _isLoadingAd = true;
    AppOpenAd.load(
      adUnitId: AdsConfig.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isAdAvailable = true;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _isAdAvailable = false;
          _isLoadingAd = false;
        },
      ),
    );
  }

  /// Shows a loaded App Open ad if every guard passes. Returns true if an ad was
  /// presented, false if it no-opped.
  bool showIfAvailable({required bool adsEnabled}) {
    if (!_canShow(adsEnabled: adsEnabled)) {
      return false;
    }

    _isShowingAd = true;
    _isAdAvailable = false;
    _lastShownAt = _now();

    final override = presentOverride;
    if (override != null) {
      override();
    } else {
      _presentAd();
    }
    return true;
  }

  bool _canShow({required bool adsEnabled}) {
    if (!adsEnabled) {
      return false;
    }
    if (!_isAdAvailable) {
      return false;
    }
    if (_isShowingAd) {
      return false;
    }
    if (_interstitialIsShowing()) {
      return false;
    }
    return _intervalElapsed();
  }

  bool _intervalElapsed() {
    final last = _lastShownAt;
    if (last == null) {
      return true;
    }
    return _now().difference(last) >= AdsConfig.appOpenMinInterval;
  }

  void _presentAd() {
    final ad = _ad;
    if (ad == null) {
      // Guarded against in _canShow, but stay defensive.
      _isShowingAd = false;
      load();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _ad = null;
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _isShowingAd = false;
        ad.dispose();
        _ad = null;
        load();
      },
    );
    ad.show();
    _ad = null;
  }

  // --- Test-only seams for simulating loaded/showing state. ---

  @visibleForTesting
  void debugSetAdAvailable(bool value) => _isAdAvailable = value;

  @visibleForTesting
  void debugSetShowing(bool value) => _isShowingAd = value;

  @visibleForTesting
  DateTime? get debugLastShownAt => _lastShownAt;
}
