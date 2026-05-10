import 'package:age_calculator/core/utils/date_utils.dart';
import 'package:age_calculator/features/age_calculator/domain/models/age_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeResult', () {
    test('empty result uses unset defaults', () {
      final result = AgeResult.empty();
      final emptyDate = DateTime.fromMillisecondsSinceEpoch(0);

      expect(result.years, 0);
      expect(result.months, 0);
      expect(result.days, 0);
      expect(result.totalDays, 0);
      expect(result.totalHours, 0);
      expect(result.totalMinutes, 0);
      expect(result.daysUntilNextBirthday, 0);
      expect(result.dayOfWeekBorn, '');
      expect(result.birthDate, emptyDate);
      expect(result.asOfDate, emptyDate);
      expect(result.isEmpty, isTrue);
    });

    test('implements value equality', () {
      final first = AppDateUtils.calculateAge(
        DateTime(1995, 6, 15),
        DateTime(2026, 4, 20),
      );
      final second = AppDateUtils.calculateAge(
        DateTime(1995, 6, 15, 18, 30),
        DateTime(2026, 4, 20, 23, 59),
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.toString(), contains('AgeResult('));
    });
  });

  group('AppDateUtils.calculateAge', () {
    test('calculates exact year match with zero months and days', () {
      final result = AppDateUtils.calculateAge(
        DateTime(1995, 6, 15),
        DateTime(2025, 6, 15),
      );

      expect(result.years, 30);
      expect(result.months, 0);
      expect(result.days, 0);
      expect(result.daysUntilNextBirthday, 0);
    });

    test('normalizes time and calculates exact age', () {
      final result = AppDateUtils.calculateAge(
        DateTime(1995, 6, 15, 12, 30),
        DateTime(2026, 4, 20, 23, 59),
      );

      expect(result.birthDate, DateTime(1995, 6, 15));
      expect(result.asOfDate, DateTime(2026, 4, 20));
      expect(result.years, 30);
      expect(result.months, 10);
      expect(result.days, 5);
      expect(result.totalDays, 11267);
      expect(result.totalHours, 270408);
      expect(result.totalMinutes, 16224480);
      expect(result.daysUntilNextBirthday, 56);
      expect(result.dayOfWeekBorn, 'Thursday');
      expect(result.totalDays, greaterThan(0));
    });

    test('throws when birth date is after reference date', () {
      expect(
        () => AppDateUtils.calculateAge(
          DateTime(2026, 4, 21),
          DateTime(2026, 4, 20),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Birth date cannot be after the reference date',
          ),
        ),
      );
    });

    test('handles month-end dates', () {
      final result = AppDateUtils.calculateAge(
        DateTime(2025, 1, 31),
        DateTime(2025, 2, 28),
      );

      expect(result.years, 0);
      expect(result.months, 1);
      expect(result.days, 0);
      expect(result.totalDays, 28);
    });

    test('handles leap-day birthdays in non-leap years', () {
      final result = AppDateUtils.calculateAge(
        DateTime(2000, 2, 29),
        DateTime(2025, 2, 28),
      );

      expect(result.years, 25);
      expect(result.months, 0);
      expect(result.days, 0);
      expect(result.daysUntilNextBirthday, 0);
      expect(result.dayOfWeekBorn, 'Tuesday');
    });

    test('handles leap-day birthdays in leap-year targets', () {
      final result = AppDateUtils.calculateAge(
        DateTime(2000, 2, 29),
        DateTime(2024, 2, 29),
      );

      expect(result.years, 24);
      expect(result.months, 0);
      expect(result.days, 0);
      expect(result.daysUntilNextBirthday, 0);
    });

    test('returns zero days until birthday when birthday is today', () {
      final result = AppDateUtils.calculateAge(
        DateTime(1995, 6, 15),
        DateTime(2026, 6, 15),
      );

      expect(result.daysUntilNextBirthday, 0);
    });

    test('returns one day until birthday when birthday is tomorrow', () {
      final result = AppDateUtils.calculateAge(
        DateTime(1995, 6, 15),
        DateTime(2026, 6, 14),
      );

      expect(result.daysUntilNextBirthday, 1);
    });
  });

  group('AppDateUtils.formatLargeInteger', () {
    test('formats large numbers with thousands separators', () {
      expect(AppDateUtils.formatLargeInteger(10836), '10,836');
      expect(AppDateUtils.formatLargeInteger(16224480), '16,224,480');
    });
  });
}
