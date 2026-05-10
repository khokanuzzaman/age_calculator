class AgeResult {
  const AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.totalHours,
    required this.totalMinutes,
    required this.daysUntilNextBirthday,
    required this.dayOfWeekBorn,
    required this.birthDate,
    required this.asOfDate,
  });

  factory AgeResult.empty() {
    final emptyDate = DateTime.fromMillisecondsSinceEpoch(0);

    return AgeResult(
      years: 0,
      months: 0,
      days: 0,
      totalDays: 0,
      totalHours: 0,
      totalMinutes: 0,
      daysUntilNextBirthday: 0,
      dayOfWeekBorn: '',
      birthDate: emptyDate,
      asOfDate: emptyDate,
    );
  }

  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int totalHours;
  final int totalMinutes;
  final int daysUntilNextBirthday;
  final String dayOfWeekBorn;
  final DateTime birthDate;
  final DateTime asOfDate;

  bool get isEmpty {
    return totalDays == 0 && years == 0 && months == 0 && days == 0;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AgeResult &&
            runtimeType == other.runtimeType &&
            years == other.years &&
            months == other.months &&
            days == other.days &&
            totalDays == other.totalDays &&
            totalHours == other.totalHours &&
            totalMinutes == other.totalMinutes &&
            daysUntilNextBirthday == other.daysUntilNextBirthday &&
            dayOfWeekBorn == other.dayOfWeekBorn &&
            birthDate == other.birthDate &&
            asOfDate == other.asOfDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      years,
      months,
      days,
      totalDays,
      totalHours,
      totalMinutes,
      daysUntilNextBirthday,
      dayOfWeekBorn,
      birthDate,
      asOfDate,
    );
  }

  @override
  String toString() {
    return 'AgeResult('
        'years: $years, '
        'months: $months, '
        'days: $days, '
        'totalDays: $totalDays, '
        'totalHours: $totalHours, '
        'totalMinutes: $totalMinutes, '
        'daysUntilNextBirthday: $daysUntilNextBirthday, '
        'dayOfWeekBorn: $dayOfWeekBorn, '
        'birthDate: $birthDate, '
        'asOfDate: $asOfDate'
        ')';
  }
}
