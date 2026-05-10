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
