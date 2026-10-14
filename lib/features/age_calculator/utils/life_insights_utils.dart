import '../../../core/utils/date_utils.dart';

/// One upcoming birthday occurrence.
class UpcomingBirthday {
  const UpcomingBirthday({
    required this.date,
    required this.turningAge,
    required this.daysAway,
    required this.weekday,
  });

  final DateTime date;
  final int turningAge;
  final int daysAway;
  final String weekday;
}

/// A life-stage age milestone (e.g. turning 18).
class LifeStageMilestone {
  const LifeStageMilestone({
    required this.age,
    required this.label,
    required this.date,
    required this.remainingDays,
  });

  final int age;
  final String label;
  final DateTime date;

  /// Negative when the milestone is already in the past.
  final int remainingDays;

  bool get reached => remainingDays < 0;
}

/// Pure, side-effect-free helpers for extra "insight" facts.
class LifeInsightsUtils {
  LifeInsightsUtils._();

  static const List<(int, String)> lifeStages = [
    (18, 'Adulthood'),
    (21, 'Turning 21'),
    (30, 'Turning 30'),
    (40, 'Turning 40'),
    (50, 'Turning 50'),
    (60, 'Turning 60'),
    (65, 'Senior citizen'),
  ];

  /// The next [count] birthdays starting from [today] (today included).
  ///
  /// Feb 29 births fall back to Feb 28 in non-leap years, matching
  /// `AppDateUtils.birthdayInYear`.
  static List<UpcomingBirthday> upcomingBirthdays(
    DateTime birthDate,
    DateTime today, {
    int count = 10,
  }) {
    final birth = AppDateUtils.dateOnly(birthDate);
    final now = AppDateUtils.dateOnly(today);

    var year = now.year;
    final first = AppDateUtils.birthdayInYear(birth, year);
    if (first.isBefore(now)) {
      year += 1;
    }

    final result = <UpcomingBirthday>[];
    for (var i = 0; i < count; i++) {
      final date = AppDateUtils.birthdayInYear(birth, year + i);
      result.add(
        UpcomingBirthday(
          date: date,
          turningAge: (year + i) - birth.year,
          daysAway: date.difference(now).inDays,
          weekday: AppDateUtils.weekdayName(date),
        ),
      );
    }
    return result;
  }

  /// Life-stage milestones, upcoming first (soonest first) then reached ones
  /// (most recent first). Reached milestones are included so the UI can show a
  /// check. A milestone dated today counts as not reached.
  static List<LifeStageMilestone> lifeStageMilestones(
    DateTime birthDate,
    DateTime today,
  ) {
    final birth = AppDateUtils.dateOnly(birthDate);
    final now = AppDateUtils.dateOnly(today);

    final all = lifeStages.map((stage) {
      final date = AppDateUtils.birthdayInYear(birth, birth.year + stage.$1);
      return LifeStageMilestone(
        age: stage.$1,
        label: stage.$2,
        date: date,
        remainingDays: date.difference(now).inDays,
      );
    }).toList();

    final upcoming = all.where((m) => !m.reached).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final reached = all.where((m) => m.reached).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return [...upcoming, ...reached];
  }

  /// Generation label from the birth year (Pew-style cut-offs).
  static String generation(int birthYear) {
    if (birthYear >= 2013) return 'Generation Alpha';
    if (birthYear >= 1997) return 'Generation Z';
    if (birthYear >= 1981) return 'Millennial';
    if (birthYear >= 1965) return 'Generation X';
    if (birthYear >= 1946) return 'Baby Boomer';
    return 'Silent Generation';
  }

  /// Meteorological season of the birth month.
  ///
  /// Defaults to the northern hemisphere; pass `northern: false` to flip.
  static String birthSeason(int month, {bool northern = true}) {
    final String season;
    if (month == 12 || month <= 2) {
      season = 'Winter';
    } else if (month <= 5) {
      season = 'Spring';
    } else if (month <= 8) {
      season = 'Summer';
    } else {
      season = 'Autumn';
    }
    if (northern) return season;
    return switch (season) {
      'Winter' => 'Summer',
      'Summer' => 'Winter',
      'Spring' => 'Autumn',
      _ => 'Spring',
    };
  }
}
