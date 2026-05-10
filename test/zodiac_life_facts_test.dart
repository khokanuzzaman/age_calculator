import 'package:age_calculator/features/age_calculator/utils/life_facts_utils.dart';
import 'package:age_calculator/features/age_calculator/utils/zodiac_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZodiacUtils western sign', () {
    test('resolves signs across cusp boundaries', () {
      expect(ZodiacUtils.fromBirthDate(DateTime(1990, 1, 1)).westernSign,
          'Capricorn');
      expect(ZodiacUtils.fromBirthDate(DateTime(1990, 1, 20)).westernSign,
          'Aquarius');
      expect(ZodiacUtils.fromBirthDate(DateTime(1990, 3, 21)).westernSign,
          'Aries');
      expect(ZodiacUtils.fromBirthDate(DateTime(1990, 12, 21)).westernSign,
          'Sagittarius');
      expect(ZodiacUtils.fromBirthDate(DateTime(1990, 12, 22)).westernSign,
          'Capricorn');
    });
  });

  group('ZodiacUtils Chinese zodiac', () {
    test('maps animal and element by year', () {
      final info = ZodiacUtils.fromBirthDate(DateTime(2000, 6, 15));
      expect(info.chineseAnimal, 'Dragon'); // 2000 is the year of the Dragon
      expect(info.chineseElement, 'Metal'); // 2000 → Metal stem
    });

    test('cycles back correctly for older years', () {
      expect(ZodiacUtils.fromBirthDate(DateTime(1996)).chineseAnimal, 'Rat');
    });
  });

  group('ZodiacUtils birthstone and flower', () {
    test('returns month-based values', () {
      final july = ZodiacUtils.fromBirthDate(DateTime(1990, 7, 4));
      expect(july.birthstone, 'Ruby');
      expect(july.birthFlower, 'Larkspur');
    });
  });

  group('LifeFactsUtils', () {
    test('produces a non-empty list of formatted facts', () {
      final facts = LifeFactsUtils.fromTotalDays(10000);
      expect(facts, isNotEmpty);
      expect(facts.every((f) => f.value.isNotEmpty), isTrue);
    });

    test('scales heartbeats into the billions for a long life', () {
      final facts = LifeFactsUtils.fromTotalDays(25000); // ~68 years
      final heartbeats = facts.firstWhere((f) => f.label == 'Heartbeats');
      expect(heartbeats.value, contains('billion'));
    });

    test('handles zero and negative days safely', () {
      expect(LifeFactsUtils.fromTotalDays(0), isNotEmpty);
      expect(LifeFactsUtils.fromTotalDays(-5), isNotEmpty);
    });
  });
}
