import 'package:age_calculator/core/utils/date_utils.dart';
import 'package:age_calculator/features/date_tools/utils/calendar_date_utils.dart';
import 'package:age_calculator/features/date_tools/utils/countdown_utils.dart';
import 'package:age_calculator/features/date_tools/utils/date_add_subtract_utils.dart';
import 'package:age_calculator/features/date_tools/utils/dob_finder_utils.dart';
import 'package:age_calculator/features/date_tools/utils/weekday_finder_utils.dart';
import 'package:age_calculator/features/date_tools/utils/working_days_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDateUtils', () {
    test('clamps January 31 to February in a common year', () {
      expect(
        CalendarDateUtils.addMonths(DateTime(2025, 1, 31), 1),
        DateTime(2025, 2, 28),
      );
    });

    test('clamps January 31 to February in a leap year', () {
      expect(
        CalendarDateUtils.addMonths(DateTime(2024, 1, 31), 1),
        DateTime(2024, 2, 29),
      );
    });

    test('clamps March 31 when subtracting a month', () {
      expect(
        CalendarDateUtils.subtractMonths(DateTime(2025, 3, 31), 1),
        DateTime(2025, 2, 28),
      );
    });

    test('clamps February 29 when adding or subtracting a year', () {
      expect(
        CalendarDateUtils.addYears(DateTime(2024, 2, 29), 1),
        DateTime(2025, 2, 28),
      );
      expect(
        CalendarDateUtils.subtractYears(DateTime(2024, 2, 29), 1),
        DateTime(2023, 2, 28),
      );
    });

    test('twelve months and week/day operations are date-only', () {
      final date = DateTime(2024, 1, 31, 23, 30);
      expect(CalendarDateUtils.addMonths(date, 12), DateTime(2025, 1, 31));
      expect(CalendarDateUtils.addWeeks(date, 2), DateTime(2024, 2, 14));
      expect(CalendarDateUtils.subtractWeeks(date, 1), DateTime(2024, 1, 24));
      expect(CalendarDateUtils.addDays(date, 1), DateTime(2024, 2, 1));
      expect(AppDateUtils.dateOnly(date), DateTime(2024, 1, 31));
    });

    test('combined operations apply years/months before weeks/days', () {
      expect(
        CalendarDateUtils.apply(
          date: DateTime(2024, 1, 31),
          years: 1,
          months: 1,
          weeks: 1,
          days: 2,
        ),
        DateTime(2025, 3, 9),
      );
    });
  });

  test('date add subtract returns a calendar-safe result', () {
    final result = DateAddSubtractUtils.calculate(
      startDate: DateTime(2026, 9, 23),
      operation: DateOperation.add,
      years: 0,
      months: 1,
      weeks: 1,
      days: 0,
    );
    expect(result.resultDate, DateTime(2026, 10, 30));
  });

  group('WorkingDaysUtils', () {
    test('counts an inclusive Monday-Friday range', () {
      final result = WorkingDaysUtils.calculate(
        startDate: DateTime(2026, 9, 21),
        endDate: DateTime(2026, 9, 25),
      );
      expect(result.totalCalendarDays, 5);
      expect(result.workingDays, 5);
      expect(result.weekendDays, 0);
    });

    test('counts Saturday and Sunday weekends', () {
      final result = WorkingDaysUtils.calculate(
        startDate: DateTime(2026, 9, 21),
        endDate: DateTime(2026, 9, 27),
      );
      expect(result.totalCalendarDays, 7);
      expect(result.workingDays, 5);
      expect(result.weekendDays, 2);
    });

    test('supports Friday and Saturday weekends', () {
      final result = WorkingDaysUtils.calculate(
        startDate: DateTime(2026, 9, 20),
        endDate: DateTime(2026, 9, 26),
        weekendPattern: WeekendPattern.friSat,
      );
      expect(result.workingDays, 5);
      expect(result.weekendDays, 2);
    });

    test('handles same-day weekday and weekend', () {
      expect(
        WorkingDaysUtils.calculate(
          startDate: DateTime(2026, 9, 21),
          endDate: DateTime(2026, 9, 21),
        ).workingDays,
        1,
      );
      expect(
        WorkingDaysUtils.calculate(
          startDate: DateTime(2026, 9, 20),
          endDate: DateTime(2026, 9, 20),
        ).workingDays,
        0,
      );
    });

    test('rejects reverse ranges and handles month/year boundaries', () {
      expect(
        () => WorkingDaysUtils.calculate(
          startDate: DateTime(2026, 9, 22),
          endDate: DateTime(2026, 9, 21),
        ),
        throwsArgumentError,
      );
      expect(
        WorkingDaysUtils.calculate(
          startDate: DateTime(2025, 12, 31),
          endDate: DateTime(2026, 1, 2),
        ).totalCalendarDays,
        3,
      );
    });
  });

  test('weekday finder handles a leap date', () {
    final result = WeekdayFinderUtils.calculate(DateTime(2024, 2, 29));
    expect(result.weekday, 'Thursday');
    expect(result.isLeapYear, isTrue);
  });

  group('DobFinderUtils', () {
    test('finds a typical exact age and round-trips', () {
      final result = DobFinderUtils.calculate(
        asOfDate: DateTime(2026, 9, 23),
        years: 30,
        months: 4,
        days: 14,
      );
      expect(result, isNotNull);
      final roundTrip = AppDateUtils.calculateAge(
        result!.birthDate,
        result.asOfDate,
      );
      expect(roundTrip.years, 30);
      expect(roundTrip.months, 4);
      expect(roundTrip.days, 14);
    });

    test('supports zero months and zero days', () {
      final monthsZero = DobFinderUtils.calculate(
        asOfDate: DateTime(2026, 9, 23),
        years: 30,
        months: 0,
        days: 14,
      );
      final daysZero = DobFinderUtils.calculate(
        asOfDate: DateTime(2026, 9, 23),
        years: 30,
        months: 4,
        days: 0,
      );
      expect(monthsZero, isNotNull);
      expect(daysZero, isNotNull);
    });

    test('round-trips month-end and leap-day cases', () {
      for (final input in [
        (DateTime(2026, 2, 28), 25, 0, 0),
        (DateTime(2025, 2, 28), 25, 0, 0),
        (DateTime(2024, 2, 29), 24, 0, 0),
      ]) {
        final result = DobFinderUtils.calculate(
          asOfDate: input.$1,
          years: input.$2,
          months: input.$3,
          days: input.$4,
        );
        expect(result, isNotNull);
        final age = AppDateUtils.calculateAge(result!.birthDate, input.$1);
        expect(
          (age.years, age.months, age.days),
          (input.$2, input.$3, input.$4),
        );
      }
    });

    test('rejects invalid and impossible components', () {
      expect(DobFinderUtils.validate(years: 0, months: 0, days: 0), isNotNull);
      expect(DobFinderUtils.validate(years: 1, months: 12, days: 0), isNotNull);
      expect(DobFinderUtils.validate(years: 1, months: 0, days: 32), isNotNull);
      expect(
        DobFinderUtils.calculate(
          asOfDate: DateTime(1, 1, 1),
          years: 1,
          months: 0,
          days: 0,
        ),
        isNull,
      );
    });
  });

  group('CountdownUtils', () {
    test('handles future, past, and today', () {
      final reference = DateTime(2026, 9, 23);
      expect(
        CountdownUtils.calculate(
          targetDate: DateTime(2026, 10, 5),
          today: reference,
        ).direction,
        CountdownDirection.future,
      );
      expect(
        CountdownUtils.calculate(
          targetDate: DateTime(2026, 9, 1),
          today: reference,
        ).direction,
        CountdownDirection.past,
      );
      expect(
        CountdownUtils.calculate(
          targetDate: reference,
          today: reference,
        ).direction,
        CountdownDirection.today,
      );
    });
  });
}
