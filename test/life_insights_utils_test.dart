import 'package:age_calculator/features/age_calculator/utils/life_insights_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('upcomingBirthdays', () {
    test('returns 10 occurrences starting with the next birthday', () {
      final list = LifeInsightsUtils.upcomingBirthdays(
        DateTime(1995, 8, 15),
        DateTime(2026, 5, 10),
      );
      expect(list.length, 10);
      expect(list.first.date, DateTime(2026, 8, 15));
      expect(list.first.turningAge, 31);
      expect(list.first.daysAway, 97);
      expect(list.last.date, DateTime(2035, 8, 15));
      expect(list.last.turningAge, 40);
    });

    test('reports the weekday of each birthday', () {
      final list = LifeInsightsUtils.upcomingBirthdays(
        DateTime(1995, 8, 15),
        DateTime(2026, 5, 10),
        count: 1,
      );
      // 15 Aug 2026 is a Saturday.
      expect(list.single.weekday, 'Saturday');
    });

    test('birthday today counts as 0 days away', () {
      final list = LifeInsightsUtils.upcomingBirthdays(
        DateTime(2000, 6, 1),
        DateTime(2026, 6, 1),
        count: 2,
      );
      expect(list.first.date, DateTime(2026, 6, 1));
      expect(list.first.daysAway, 0);
      expect(list.first.turningAge, 26);
      expect(list[1].date, DateTime(2027, 6, 1));
    });

    test('passed birthday rolls to next year', () {
      final list = LifeInsightsUtils.upcomingBirthdays(
        DateTime(2000, 1, 10),
        DateTime(2026, 6, 1),
        count: 1,
      );
      expect(list.single.date, DateTime(2027, 1, 10));
      expect(list.single.turningAge, 27);
    });

    test('ignores the time of day of the reference date', () {
      final list = LifeInsightsUtils.upcomingBirthdays(
        DateTime(2000, 6, 1),
        DateTime(2026, 6, 1, 23, 59),
        count: 1,
      );
      expect(list.single.daysAway, 0);
    });

    test('Feb 29 falls back to Feb 28 in non-leap years', () {
      final list = LifeInsightsUtils.upcomingBirthdays(
        DateTime(2000, 2, 29),
        DateTime(2026, 3, 1),
        count: 4,
      );
      expect(list[0].date, DateTime(2027, 2, 28));
      expect(list[1].date, DateTime(2028, 2, 29));
      expect(list[2].date, DateTime(2029, 2, 28));
    });
  });

  group('lifeStageMilestones', () {
    test('separates upcoming and reached, upcoming first', () {
      final list = LifeInsightsUtils.lifeStageMilestones(
        DateTime(2000, 1, 1),
        DateTime(2026, 6, 1),
      );
      expect(list.length, LifeInsightsUtils.lifeStages.length);
      // 18 and 21 are reached (2018, 2021); 30 is the first upcoming.
      expect(list.first.age, 30);
      expect(list.first.reached, isFalse);
      final reached = list.where((m) => m.reached).map((m) => m.age).toList();
      expect(reached, [21, 18]);
    });

    test('upcoming milestones are ordered soonest first', () {
      final list = LifeInsightsUtils.lifeStageMilestones(
        DateTime(2000, 1, 1),
        DateTime(2026, 6, 1),
      );
      final upcoming = list.where((m) => !m.reached).map((m) => m.age).toList();
      expect(upcoming, [30, 40, 50, 60, 65]);
    });

    test('milestone dated today is not reached', () {
      final list = LifeInsightsUtils.lifeStageMilestones(
        DateTime(2000, 6, 1),
        DateTime(2018, 6, 1),
      );
      final eighteen = list.firstWhere((m) => m.age == 18);
      expect(eighteen.remainingDays, 0);
      expect(eighteen.reached, isFalse);
      expect(list.first.age, 18);
    });
  });

  group('generation', () {
    test('boundaries', () {
      expect(LifeInsightsUtils.generation(2013), 'Generation Alpha');
      expect(LifeInsightsUtils.generation(2012), 'Generation Z');
      expect(LifeInsightsUtils.generation(1997), 'Generation Z');
      expect(LifeInsightsUtils.generation(1996), 'Millennial');
      expect(LifeInsightsUtils.generation(1981), 'Millennial');
      expect(LifeInsightsUtils.generation(1980), 'Generation X');
      expect(LifeInsightsUtils.generation(1965), 'Generation X');
      expect(LifeInsightsUtils.generation(1964), 'Baby Boomer');
      expect(LifeInsightsUtils.generation(1946), 'Baby Boomer');
      expect(LifeInsightsUtils.generation(1945), 'Silent Generation');
    });
  });

  group('birthSeason', () {
    test('northern hemisphere', () {
      expect(LifeInsightsUtils.birthSeason(12), 'Winter');
      expect(LifeInsightsUtils.birthSeason(1), 'Winter');
      expect(LifeInsightsUtils.birthSeason(2), 'Winter');
      expect(LifeInsightsUtils.birthSeason(3), 'Spring');
      expect(LifeInsightsUtils.birthSeason(4), 'Spring');
      expect(LifeInsightsUtils.birthSeason(7), 'Summer');
      expect(LifeInsightsUtils.birthSeason(9), 'Autumn');
      expect(LifeInsightsUtils.birthSeason(10), 'Autumn');
    });

    test('southern hemisphere flips', () {
      expect(LifeInsightsUtils.birthSeason(12, northern: false), 'Summer');
      expect(LifeInsightsUtils.birthSeason(7, northern: false), 'Winter');
      expect(LifeInsightsUtils.birthSeason(4, northern: false), 'Autumn');
      expect(LifeInsightsUtils.birthSeason(10, northern: false), 'Spring');
    });
  });
}
