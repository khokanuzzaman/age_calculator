import 'package:age_calculator/features/age_calculator/utils/age_calculation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeCalculationUtils.nextDayMilestone', () {
    final birth = DateTime(2000, 1, 1);

    test('returns the next multiple of 1000 days', () {
      final now = DateTime(2000, 1, 1 + 9999); // 9999 days lived
      final milestone = AgeCalculationUtils.nextDayMilestone(birth, now);
      expect(milestone.days, 10000);
      expect(milestone.date, DateTime(2000, 1, 1 + 10000));
    });

    test('when a milestone is exactly today, returns today', () {
      final now = DateTime(2000, 1, 1 + 10000); // exactly 10000 days lived
      final milestone = AgeCalculationUtils.nextDayMilestone(birth, now);
      expect(milestone.days, 10000);
      expect(milestone.date, DateTime(2000, 1, 1 + 10000));
    });

    test('when a milestone just passed, targets the next one', () {
      final now = DateTime(2000, 1, 1 + 10001); // 10001 days lived
      final milestone = AgeCalculationUtils.nextDayMilestone(birth, now);
      expect(milestone.days, 11000);
      expect(milestone.date, DateTime(2000, 1, 1 + 11000));
    });

    test('newborn floors to the first milestone', () {
      final milestone = AgeCalculationUtils.nextDayMilestone(birth, birth);
      expect(milestone.days, 1000);
      expect(milestone.date, DateTime(2000, 1, 1 + 1000));
    });

    test('respects a custom step', () {
      final now = DateTime(2000, 1, 1 + 500);
      final milestone = AgeCalculationUtils.nextDayMilestone(
        birth,
        now,
        step: 365,
      );
      expect(milestone.days, 730); // next multiple of 365 after 500
    });
  });

  group('AgeCalculationUtils.birthdayCountdownLeads', () {
    final birth = DateTime(1990, 6, 15);

    test('computes 7/1/0-day leads for an upcoming birthday', () {
      final now = DateTime(2026, 1, 1); // birthday later this year
      final leads = AgeCalculationUtils.birthdayCountdownLeads(birth, now);

      expect(leads.map((l) => l.daysBefore).toList(), [7, 1, 0]);
      expect(leads[0].date, DateTime(2026, 6, 8)); // 7 days before
      expect(leads[1].date, DateTime(2026, 6, 14)); // 1 day before
      expect(leads[2].date, DateTime(2026, 6, 15)); // the day itself
    });

    test('rolls over to next year when this year\'s birthday has passed', () {
      final now = DateTime(2026, 8, 1); // already past June 15, 2026
      final leads = AgeCalculationUtils.birthdayCountdownLeads(birth, now);

      expect(leads[2].date, DateTime(2027, 6, 15)); // next year's birthday
      expect(leads[0].date, DateTime(2027, 6, 8));
      expect(leads[1].date, DateTime(2027, 6, 14));
    });

    test('same-day: on the birthday, the 0-lead targets today', () {
      final now = DateTime(2026, 6, 15);
      final leads = AgeCalculationUtils.birthdayCountdownLeads(birth, now);
      expect(leads[2].date, DateTime(2026, 6, 15));
    });

    test('honours a custom lead-day list', () {
      final now = DateTime(2026, 1, 1);
      final leads = AgeCalculationUtils.birthdayCountdownLeads(
        birth,
        now,
        leadDays: const [30, 0],
      );
      expect(leads.map((l) => l.daysBefore).toList(), [30, 0]);
      expect(leads[0].date, DateTime(2026, 5, 16)); // 30 days before Jun 15
    });
  });
}
