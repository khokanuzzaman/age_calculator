import 'package:age_calculator/features/age_calculator/utils/age_calculation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeCalculationUtils.widgetData', () {
    test('birthday today → 0 days until next birthday', () {
      final data = AgeCalculationUtils.widgetData(
        DateTime(2000, 6, 15),
        DateTime(2020, 6, 15),
      );
      expect(data.years, 20);
      expect(data.ageText, '20 years');
      expect(data.daysUntilNextBirthday, 0);
    });

    test('birthday tomorrow → 1 day, age not yet incremented', () {
      final data = AgeCalculationUtils.widgetData(
        DateTime(2000, 6, 15),
        DateTime(2020, 6, 14),
      );
      expect(data.years, 19);
      expect(data.daysUntilNextBirthday, 1);
    });

    test('exact birthday boundary increments age on the day', () {
      final dayBefore = AgeCalculationUtils.widgetData(
        DateTime(1995, 3, 10),
        DateTime(2025, 3, 9),
      );
      final onDay = AgeCalculationUtils.widgetData(
        DateTime(1995, 3, 10),
        DateTime(2025, 3, 10),
      );
      expect(dayBefore.years, 29);
      expect(dayBefore.daysUntilNextBirthday, 1);
      expect(onDay.years, 30);
      expect(onDay.daysUntilNextBirthday, 0);
    });

    test('Feb-29 birth: leap-year boundary is exact', () {
      final data = AgeCalculationUtils.widgetData(
        DateTime(2004, 2, 29),
        DateTime(2024, 2, 29),
      );
      expect(data.years, 20);
      expect(data.daysUntilNextBirthday, 0);
    });

    test('Feb-29 birth in a non-leap year still computes a valid countdown', () {
      final data = AgeCalculationUtils.widgetData(
        DateTime(2004, 2, 29),
        DateTime(2023, 3, 1), // day after the observed Feb-28 birthday
      );
      expect(data.years, 19);
      expect(data.daysUntilNextBirthday, greaterThan(0));
      expect(data.daysUntilNextBirthday, lessThanOrEqualTo(366));
    });

    test('singular "1 year" copy', () {
      final data = AgeCalculationUtils.widgetData(
        DateTime(2019, 6, 15),
        DateTime(2020, 6, 15),
      );
      expect(data.ageText, '1 year');
    });
  });
}
