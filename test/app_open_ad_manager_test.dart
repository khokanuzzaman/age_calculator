import 'package:age_calculator/core/ads/app_open_ad_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A controllable clock and interstitial flag so the guard/cap logic can be
  // exercised without the Ads SDK.
  late DateTime clock;
  late bool interstitialShowing;
  late int presentCount;

  AppOpenAdManager build() {
    final manager = AppOpenAdManager.forTest(
      now: () => clock,
      interstitialIsShowing: () => interstitialShowing,
    );
    // Simulate a loaded ad and capture "show" without hitting the SDK.
    manager
      ..debugSetAdAvailable(true)
      ..presentOverride = () => presentCount++;
    return manager;
  }

  setUp(() {
    clock = DateTime(2026, 1, 1, 12, 0, 0);
    interstitialShowing = false;
    presentCount = 0;
  });

  test('shows when every guard passes', () {
    final manager = build();

    final shown = manager.showIfAvailable(adsEnabled: true);

    expect(shown, isTrue);
    expect(presentCount, 1);
    expect(manager.isShowing, isTrue);
    expect(manager.debugLastShownAt, clock);
  });

  test('no-op when ads are disabled', () {
    final manager = build();

    expect(manager.showIfAvailable(adsEnabled: false), isFalse);
    expect(presentCount, 0);
    expect(manager.isShowing, isFalse);
  });

  test('no-op when no ad is loaded', () {
    final manager = build()..debugSetAdAvailable(false);

    expect(manager.showIfAvailable(adsEnabled: true), isFalse);
    expect(presentCount, 0);
  });

  test('no-op when an App Open ad is already showing', () {
    final manager = build()..debugSetShowing(true);

    expect(manager.showIfAvailable(adsEnabled: true), isFalse);
    expect(presentCount, 0);
  });

  test('no-op when an interstitial is on screen', () {
    final manager = build();
    interstitialShowing = true;

    expect(manager.showIfAvailable(adsEnabled: true), isFalse);
    expect(presentCount, 0);
  });

  test('frequency cap blocks a second show until the interval elapses', () {
    final manager = build();

    // First show succeeds and records the time.
    expect(manager.showIfAvailable(adsEnabled: true), isTrue);
    expect(presentCount, 1);

    // Re-arm a loaded ad and clear the showing flag (as the SDK dismiss
    // callback would), then try again too soon.
    manager
      ..debugSetShowing(false)
      ..debugSetAdAvailable(true);

    clock = clock.add(const Duration(minutes: 3, seconds: 59));
    expect(manager.showIfAvailable(adsEnabled: true), isFalse);
    expect(presentCount, 1, reason: 'still within the 4-minute cap');

    // Once the full interval has passed, it shows again.
    clock = clock.add(const Duration(seconds: 2)); // now 4m01s since first show
    expect(manager.showIfAvailable(adsEnabled: true), isTrue);
    expect(presentCount, 2);
  });

  test('first show is allowed with no prior timestamp', () {
    final manager = build();
    expect(manager.debugLastShownAt, isNull);
    expect(manager.showIfAvailable(adsEnabled: true), isTrue);
  });
}
