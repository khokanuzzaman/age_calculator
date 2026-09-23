import '../../../core/utils/date_utils.dart';

class WeekdayFinderResult {
  const WeekdayFinderResult({required this.date, required this.weekday});

  final DateTime date;
  final String weekday;

  bool get isLeapYear => AppDateUtils.isLeapYear(date.year);
}

class WeekdayFinderUtils {
  WeekdayFinderUtils._();

  static WeekdayFinderResult calculate(DateTime date) {
    final normalized = AppDateUtils.dateOnly(date);
    return WeekdayFinderResult(
      date: normalized,
      weekday: AppDateUtils.weekdayName(normalized),
    );
  }
}
