import '../../../../core/utils/date_utils.dart';

class DateDifferenceResult {
  const DateDifferenceResult({
    required this.startDate,
    required this.endDate,
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.totalWeeks,
    required this.remainingDays,
    required this.totalMonths,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int totalWeeks;
  final int remainingDays;
  final int totalMonths;
}

class DateDifferenceUtils {
  DateDifferenceUtils._();

  static const String validationMessage = 'End date should be after start date';

  static bool isValidRange(DateTime startDate, DateTime endDate) {
    return !AppDateUtils.isAfterDay(startDate, endDate);
  }

  static DateDifferenceResult calculate(DateTime startDate, DateTime endDate) {
    final result = AppDateUtils.calculateAge(startDate, endDate);
    final totalWeeks = result.totalDays ~/ 7;
    final remainingDays = result.totalDays % 7;

    return DateDifferenceResult(
      startDate: result.birthDate,
      endDate: result.asOfDate,
      years: result.years,
      months: result.months,
      days: result.days,
      totalDays: result.totalDays,
      totalWeeks: totalWeeks,
      remainingDays: remainingDays,
      totalMonths: (result.years * 12) + result.months,
    );
  }
}
