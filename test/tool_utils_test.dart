import 'package:age_calculator/features/age_difference/utils/age_difference_utils.dart';
import 'package:age_calculator/features/date_difference/utils/date_difference_utils.dart';
import 'package:age_calculator/features/leap_year/utils/leap_year_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateDifferenceUtils', () {
    test('calculates exact span between two dates', () {
      final result = DateDifferenceUtils.calculate(
        DateTime(2022, 1, 1),
        DateTime(2024, 5, 8),
      );

      expect(result.years, 2);
      expect(result.months, 4);
      expect(result.days, 7);
      expect(result.totalDays, 858);
      expect(result.totalWeeks, 122);
      expect(result.remainingDays, 4);
      expect(result.totalMonths, 28);
    });

    test('allows same date and returns zero span', () {
      final result = DateDifferenceUtils.calculate(
        DateTime(2024, 5, 8),
        DateTime(2024, 5, 8),
      );

      expect(result.totalDays, 0);
      expect(result.years, 0);
      expect(result.months, 0);
      expect(result.days, 0);
    });

    test('rejects reverse date order', () {
      expect(
        DateDifferenceUtils.isValidRange(
          DateTime(2024, 5, 9),
          DateTime(2024, 5, 8),
        ),
        isFalse,
      );
    });
  });

  group('AgeDifferenceUtils', () {
    test('calculates age gap and older person label', () {
      final result = AgeDifferenceUtils.calculate(
        personOneBirthDate: DateTime(1990, 1, 1),
        personTwoBirthDate: DateTime(1995, 1, 1),
      );

      expect(result.isSameAge, isFalse);
      expect(result.olderLabel, 'Person 1');
      expect(result.youngerLabel, 'Person 2');
      expect(result.years, 5);
      expect(result.months, 0);
      expect(result.days, 0);
    });

    test('handles same birth date', () {
      final result = AgeDifferenceUtils.calculate(
        personOneBirthDate: DateTime(1995, 6, 15),
        personTwoBirthDate: DateTime(1995, 6, 15),
      );

      expect(result.isSameAge, isTrue);
      expect(result.totalDays, 0);
      expect(result.years, 0);
      expect(result.months, 0);
      expect(result.days, 0);
    });
  });

  group('LeapYearUtils', () {
    test('checks leap year edge cases', () {
      expect(LeapYearUtils.isLeapYear(1900), isFalse);
      expect(LeapYearUtils.isLeapYear(2000), isTrue);
      expect(LeapYearUtils.isLeapYear(2024), isTrue);
      expect(LeapYearUtils.isLeapYear(2025), isFalse);
    });

    test('returns previous and next leap years', () {
      final result = LeapYearUtils.calculate(2024);

      expect(result.previousLeapYear, 2020);
      expect(result.nextLeapYear, 2028);
      expect(result.daysInFebruary, 29);
    });

    test('validates numeric year input', () {
      expect(LeapYearUtils.validateYear(''), isNotNull);
      expect(LeapYearUtils.validateYear('abc'), isNotNull);
      expect(LeapYearUtils.validateYear('0'), isNotNull);
      expect(LeapYearUtils.validateYear('10000'), isNotNull);
      expect(LeapYearUtils.validateYear('2024'), isNull);
    });
  });
}
