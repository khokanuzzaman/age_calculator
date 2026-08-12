import 'dart:io';

/// Central AdMob configuration.
///
/// ⚠️ BEFORE RELEASE: create this app's own AdMob entry in the AdMob console
/// (you cannot reuse another app's IDs — it violates AdMob policy), then:
///   1. Set [useTestAds] to `false`.
///   2. Replace the `_prod*` IDs below with your real ad unit IDs.
///   3. Replace the AdMob App ID in AndroidManifest.xml
///      (`com.google.android.gms.ads.APPLICATION_ID`) with your real App ID.
///
/// While [useTestAds] is `true`, Google's official sample/test ad units are
/// used so you can develop safely without risking your account.
class AdsConfig {
  AdsConfig._();

  static const bool useTestAds = false;

  /// Suppresses [BannerAdWidget] entirely — it neither requests nor mounts
  /// an ad, so no "Test mode" overlay and no reserved layout space appear.
  /// For capturing clean App Store marketing screenshots only.
  ///
  /// ⚠️ Must stay `false` in any release build — flip locally for a capture
  /// session, then revert before shipping.
  static const bool kDebugHideBannerAd = false;

  // --- Google official TEST ad unit IDs ---
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppOpenAndroid =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testBannerIOS =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testAppOpenIOS =
      'ca-app-pub-3940256099942544/5575463023';

  // --- Real ad unit IDs for me.khokan.agecalculator (used when useTestAds == false) ---
  // AdMob App ID: ca-app-pub-1928074644821911~3546479443 (set in AndroidManifest).
  static const String _prodBannerAndroid =
      'ca-app-pub-1928074644821911/5243694175';
  static const String _prodInterstitialAndroid =
      'ca-app-pub-1928074644821911/5813550139';
  // TODO(owner): create an App Open ad unit in AdMob for me.khokan.agecalculator
  // and paste its real unit ID here (falls back to the TEST unit until then).
  static const String _prodAppOpenAndroid = 'YOUR_REAL_APP_OPEN_AD_UNIT_ID';

  // Real ad unit IDs for the separate iOS AdMob app entry (App ID:
  // ca-app-pub-1928074644821911~7649605868, set in ios/Runner/Info.plist).
  static const String _prodBannerIOS =
      'ca-app-pub-1928074644821911/8350645141';
  static const String _prodInterstitialIOS =
      'ca-app-pub-1928074644821911/5072961298';
  static const String _prodAppOpenIOS =
      'ca-app-pub-1928074644821911/1032226622';

  static bool get _iosProdIdsConfigured =>
      !_prodBannerIOS.startsWith('YOUR_REAL_');

  static String get bannerAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    if (Platform.isAndroid) {
      return _prodBannerAndroid;
    }
    return _iosProdIdsConfigured ? _prodBannerIOS : _testBannerIOS;
  }

  static String get interstitialAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid
          ? _testInterstitialAndroid
          : _testInterstitialIOS;
    }
    if (Platform.isAndroid) {
      return _prodInterstitialAndroid;
    }
    return _iosProdIdsConfigured ? _prodInterstitialIOS : _testInterstitialIOS;
  }

  static String get appOpenAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid ? _testAppOpenAndroid : _testAppOpenIOS;
    }
    if (Platform.isAndroid) {
      return _prodAppOpenAndroid;
    }
    return _iosProdIdsConfigured ? _prodAppOpenIOS : _testAppOpenIOS;
  }

  /// Show an interstitial at most once every [interstitialEveryNActions]
  /// qualifying actions — keeps the experience respectful (competitors get
  /// hammered in reviews for ad spam).
  static const int interstitialEveryNActions = 4;

  /// Minimum time between App Open ads, so returning to the foreground
  /// repeatedly doesn't spam the user.
  static const Duration appOpenMinInterval = Duration(minutes: 4);

  /// Devices that should always receive TEST ads (even though real ad unit IDs
  /// are used). This lets the owner test safely — tapping a *real* ad on your
  /// own device violates AdMob policy and can get the account banned.
  ///
  /// To add your phone: run the app, load an ad, and check logcat for a line
  /// like `Use ... setTestDeviceIds(Arrays.asList("ABC123..."))` — paste that
  /// hashed ID here.
  static const List<String> testDeviceIds = <String>[
    '86F322E132383FAD40F23029B90E3CDE', // Pixel 6a (dev) — current
    '24131E5E1CF760BDB504FBD51C41AF63', // Pixel 6a (older advertising id)
    'ca954eb8611c1b71a019caf44d91ced4', // SQA-iPhone-12 (dev) — iOS
    'b0db196c7d25c7cf8537d9219411ad05', // SQA-iPhone-12 (dev) — iOS, reinstall
    '51c84f274c4eae3591764a9fd4f9872c', // SQA-iPhone-12 (dev) — iOS, reinstall
    'f2e2bd056da160672938e7a407e75ab6', // SQA-iPhone-12 (dev) — iOS, reinstall
    'ead65b9c4e044351b07ba5fae53e44dd', // SQA-iPhone-12 (dev) — iOS, reinstall
    '00e33f245da6c65a374d6b073005d5fd', // SQA-iPhone-12 (dev) — iOS, reinstall
  ];
}
