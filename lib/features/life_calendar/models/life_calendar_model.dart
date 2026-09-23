class LifeEventMarker {
  const LifeEventMarker({required this.title, required this.emoji});

  final String title;
  final String emoji;
}

class LifeCalendarWeek {
  const LifeCalendarWeek({
    required this.index,
    required this.startDate,
    required this.isLived,
    required this.isCurrent,
    required this.events,
  });

  final int index;
  final DateTime startDate;
  final bool isLived;
  final bool isCurrent;
  final List<LifeEventMarker> events;

  bool get hasEvents => events.isNotEmpty;

  DateTime get endDate => startDate.add(const Duration(days: 6));
}

class LifeCalendarSummary {
  const LifeCalendarSummary({
    required this.birthDate,
    required this.today,
    required this.horizonYears,
    required this.currentAge,
    required this.currentWeekIndex,
    required this.completedWeeks,
    required this.weeks,
  });

  final DateTime birthDate;
  final DateTime today;
  final int horizonYears;
  final AgeSummary currentAge;
  final int currentWeekIndex;
  final int completedWeeks;
  final List<LifeCalendarWeek> weeks;

  int get totalWeeks => weeks.length;

  int get eventCount =>
      weeks.fold(0, (total, week) => total + week.events.length);
}

class AgeSummary {
  const AgeSummary({
    required this.years,
    required this.months,
    required this.days,
  });

  final int years;
  final int months;
  final int days;

  String get compactText => '$years years, $months months, $days days';
}
