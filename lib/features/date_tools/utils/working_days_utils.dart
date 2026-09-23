import '../../../core/utils/date_utils.dart';

enum WeekendPattern { satSun, friSat }

extension WeekendPatternLabel on WeekendPattern {
  String get label => switch (this) {
    WeekendPattern.satSun => 'Saturday & Sunday',
    WeekendPattern.friSat => 'Friday & Saturday',
  };

  String get analyticsValue => switch (this) {
    WeekendPattern.satSun => 'sat_sun',
    WeekendPattern.friSat => 'fri_sat',
  };

  bool isWeekend(int weekday) => switch (this) {
    WeekendPattern.satSun =>
      weekday == DateTime.saturday || weekday == DateTime.sunday,
    WeekendPattern.friSat =>
      weekday == DateTime.friday || weekday == DateTime.saturday,
  };
}

class WorkingDaysResult {
  const WorkingDaysResult({
    required this.startDate,
    required this.endDate,
    required this.totalCalendarDays,
    required this.workingDays,
    required this.weekendDays,
    required this.weekendPattern,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int totalCalendarDays;
  final int workingDays;
  final int weekendDays;
  final WeekendPattern weekendPattern;
}

class WorkingDaysUtils {
  WorkingDaysUtils._();

  static WorkingDaysResult calculate({
    required DateTime startDate,
    required DateTime endDate,
    WeekendPattern weekendPattern = WeekendPattern.satSun,
  }) {
    final start = AppDateUtils.dateOnly(startDate);
    final end = AppDateUtils.dateOnly(endDate);
    if (start.isAfter(end)) {
      throw ArgumentError('Start date must be on or before end date');
    }

    final totalCalendarDays = end.difference(start).inDays + 1;
    var weekendDays = 0;
    for (
      var date = start;
      !date.isAfter(end);
      date = date.add(const Duration(days: 1))
    ) {
      if (weekendPattern.isWeekend(date.weekday)) {
        weekendDays++;
      }
    }
    return WorkingDaysResult(
      startDate: start,
      endDate: end,
      totalCalendarDays: totalCalendarDays,
      workingDays: totalCalendarDays - weekendDays,
      weekendDays: weekendDays,
      weekendPattern: weekendPattern,
    );
  }
}
