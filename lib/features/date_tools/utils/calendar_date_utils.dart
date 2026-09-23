import '../../../core/utils/date_utils.dart';

/// Calendar-safe operations for date-only values.
///
/// Years and months are applied as calendar units and clamp to the last valid
/// day in the target month. Weeks and days are applied afterwards by the
/// callers that support combined operations.
class CalendarDateUtils {
  CalendarDateUtils._();

  static DateTime addYears(DateTime date, int years) {
    return addMonths(date, years * 12);
  }

  static DateTime addMonths(DateTime date, int months) {
    final source = AppDateUtils.dateOnly(date);
    final monthIndex = (source.year * 12) + (source.month - 1) + months;
    final year = monthIndex ~/ 12;
    final month = (monthIndex % 12) + 1;
    if (year < 1 || year > 9999) {
      throw RangeError('Result must remain between years 1 and 9999');
    }
    final day = source.day.clamp(1, AppDateUtils.daysInMonth(year, month));
    return DateTime(year, month, day);
  }

  static DateTime addWeeks(DateTime date, int weeks) {
    return addDays(date, weeks * 7);
  }

  static DateTime addDays(DateTime date, int days) {
    return AppDateUtils.dateOnly(date).add(Duration(days: days));
  }

  static DateTime subtractYears(DateTime date, int years) {
    return addYears(date, -years);
  }

  static DateTime subtractMonths(DateTime date, int months) {
    return addMonths(date, -months);
  }

  static DateTime subtractWeeks(DateTime date, int weeks) {
    return addWeeks(date, -weeks);
  }

  static DateTime subtractDays(DateTime date, int days) {
    return addDays(date, -days);
  }

  /// Applies years, then months, then weeks, then days.
  static DateTime apply({
    required DateTime date,
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
  }) {
    var result = addYears(date, years);
    result = addMonths(result, months);
    result = addWeeks(result, weeks);
    return addDays(result, days);
  }
}
