import '../../../core/utils/date_utils.dart';
import 'calendar_date_utils.dart';

enum DateOperation { add, subtract }

class DateAddSubtractResult {
  const DateAddSubtractResult({
    required this.startDate,
    required this.resultDate,
    required this.operation,
    required this.years,
    required this.months,
    required this.weeks,
    required this.days,
  });

  final DateTime startDate;
  final DateTime resultDate;
  final DateOperation operation;
  final int years;
  final int months;
  final int weeks;
  final int days;

  bool get isZero => years == 0 && months == 0 && weeks == 0 && days == 0;
}

class DateAddSubtractUtils {
  DateAddSubtractUtils._();

  static DateAddSubtractResult calculate({
    required DateTime startDate,
    required DateOperation operation,
    required int years,
    required int months,
    required int weeks,
    required int days,
  }) {
    if ([years, months, weeks, days].any((value) => value < 0)) {
      throw ArgumentError('Amounts cannot be negative');
    }
    final sign = operation == DateOperation.add ? 1 : -1;
    final result = CalendarDateUtils.apply(
      date: startDate,
      years: years * sign,
      months: months * sign,
      weeks: weeks * sign,
      days: days * sign,
    );
    return DateAddSubtractResult(
      startDate: AppDateUtils.dateOnly(startDate),
      resultDate: result,
      operation: operation,
      years: years,
      months: months,
      weeks: weeks,
      days: days,
    );
  }
}
