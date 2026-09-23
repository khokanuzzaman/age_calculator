import 'package:age_calculator/core/ads/ads_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a valid AdMob ad unit ID', () {
    expect(
      AdsConfig.isValidAdUnitId('ca-app-pub-1234567890123456/1234567890'),
      isTrue,
    );
  });

  test('rejects placeholders and malformed ad unit IDs', () {
    expect(AdsConfig.isValidAdUnitId('YOUR_REAL_APP_OPEN_AD_UNIT_ID'), isFalse);
    expect(AdsConfig.isValidAdUnitId(''), isFalse);
    expect(
      AdsConfig.isValidAdUnitId('ca-app-pub-1234567890123456/123'),
      isFalse,
    );
  });
}
