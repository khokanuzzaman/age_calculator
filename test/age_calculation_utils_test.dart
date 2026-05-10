import 'package:age_calculator/features/age_calculator/utils/age_calculation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeCalculationUtils next birthday', () {
    test('handles normal birthdays', () {
      final next = AgeCalculationUtils.nextBirthday(
        DateTime(1995, 8, 15),
        DateTime(2026, 5, 10),
      );
      expect(next, DateTime(2026, 8, 15));
    });

    test('handles Feb 29 fallback to Feb 28', () {
      final next = AgeCalculationUtils.nextBirthday(
        DateTime(2000, 2, 29),
        DateTime(2025, 3, 1),
      );
      expect(next, DateTime(2026, 2, 28));
    });
  });

  group('AgeCalculationUtils milestones', () {
    test('returns sorted future milestones limited to 5', () {
      final milestones = AgeCalculationUtils.upcomingMilestones(
        DateTime(2000, 1, 1),
        DateTime(2026, 1, 1),
      );

      expect(milestones.length, lessThanOrEqualTo(5));
      for (var i = 1; i < milestones.length; i++) {
        expect(
          milestones[i].targetDate.isBefore(milestones[i - 1].targetDate),
          isFalse,
        );
      }
    });
  });

  group('AgeCalculationUtils life stats', () {
    test('computes totals and progress ranges', () {
      final stats = AgeCalculationUtils.lifeStats(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 2, 12),
      );

      expect(stats.totalDays, 1);
      expect(stats.totalHours, 36);
      expect(stats.totalMinutes, 2160);
      expect(stats.totalSeconds, 129600);
      expect(stats.yearProgress, inInclusiveRange(0, 100));
      expect(stats.monthProgress, inInclusiveRange(0, 100));
      expect(stats.weekProgress, inInclusiveRange(0, 100));
    });
  });

  test('birthday details returns weekday values', () {
    final details = AgeCalculationUtils.birthdayDetails(
      DateTime(1995, 6, 15),
      DateTime(2026, 5, 10),
    );

    expect(details.bornWeekday, isNotEmpty);
    expect(details.nextBirthdayWeekday, isNotEmpty);
    expect(details.daysUntilNextBirthday, greaterThanOrEqualTo(0));
  });
}
