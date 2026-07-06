class AgeMilestone {
  const AgeMilestone({
    required this.title,
    required this.targetDate,
    required this.remainingDays,
  });

  final String title;
  final DateTime targetDate;
  final int remainingDays;
}

class LifeStats {
  const LifeStats({
    required this.totalDays,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalSeconds,
    required this.yearProgress,
    required this.monthProgress,
    required this.weekProgress,
  });

  final int totalDays;
  final int totalHours;
  final int totalMinutes;
  final int totalSeconds;
  final double yearProgress;
  final double monthProgress;
  final double weekProgress;
}

class BirthdayDetails {
  const BirthdayDetails({
    required this.bornWeekday,
    required this.nextBirthdayDate,
    required this.nextBirthdayWeekday,
    required this.daysUntilNextBirthday,
  });

  final String bornWeekday;
  final DateTime nextBirthdayDate;
  final String nextBirthdayWeekday;
  final int daysUntilNextBirthday;
}

/// The user's next round-number "days lived" milestone (e.g. 10,000 days).
class DayMilestone {
  const DayMilestone({required this.days, required this.date});

  /// The milestone count, e.g. 10000.
  final int days;

  /// The calendar date (date-only) the user reaches [days] days lived.
  final DateTime date;
}

/// A single lead-time reminder before the user's next birthday.
class BirthdayLead {
  const BirthdayLead({required this.daysBefore, required this.date});

  /// How many days before the birthday this reminder fires (0 = the day itself).
  final int daysBefore;

  /// The date-only day the reminder should fire on.
  final DateTime date;
}
