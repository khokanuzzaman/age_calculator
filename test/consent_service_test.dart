import 'package:age_calculator/core/ads/consent_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConsentService.shouldInitializeAds', () {
    test('proceeds when the SDK reports ads can be requested', () {
      expect(ConsentService.shouldInitializeAds(canRequestAds: true), isTrue);
    });

    test('skips ad init when the SDK reports ads cannot be requested', () {
      expect(
        ConsentService.shouldInitializeAds(canRequestAds: false),
        isFalse,
      );
    });
  });
}
