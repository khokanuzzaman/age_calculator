import '../../../core/utils/date_utils.dart';

class DobFinderResult {
  const DobFinderResult({
    required this.birthDate,
    required this.asOfDate,
    required this.years,
    required this.months,
    required this.days,
  });

  final DateTime birthDate;
  final DateTime asOfDate;
  final int years;
  final int months;
  final int days;
}

class DobFinderUtils {
  DobFinderUtils._();

  static String? validate({
    required int years,
    required int months,
    required int days,
  }) {
    if (years < 0) {
      return 'Years cannot be negative';
    }
    if (months < 0 || months > 11) {
      return 'Months must be between 0 and 11';
    }
    if (days < 0 || days > 31) {
      return 'Days must be between 0 and 31';
    }
    if (years == 0 && months == 0 && days == 0) {
      return 'Enter an age greater than zero';
    }
    return null;
  }

  /// Finds a candidate by searching around a calendar-aware reverse estimate.
  /// Every candidate is validated with the app's forward age calculator before
  /// it is returned, so month-end ambiguity can never produce a false result.
  static DobFinderResult? calculate({
    required DateTime asOfDate,
    required int years,
    required int months,
    required int days,
  }) {
    if (validate(years: years, months: months, days: days) != null) {
      return null;
    }
    final asOf = AppDateUtils.dateOnly(asOfDate);
    final estimate = DateTime(asOf.year - years, asOf.month, asOf.day);
    final monthIndex = (estimate.year * 12) + estimate.month - 1 - months;
    final estimateYear = monthIndex ~/ 12;
    final estimateMonth = (monthIndex % 12) + 1;
    if (estimateYear < 1) {
      return null;
    }
    final estimateDay = estimate.day.clamp(
      1,
      AppDateUtils.daysInMonth(estimateYear, estimateMonth),
    );
    final center = DateTime(
      estimateYear,
      estimateMonth,
      estimateDay,
    ).subtract(Duration(days: days));

    DobFinderResult? best;
    for (var offset = -400; offset <= 400; offset++) {
      final candidate = center.add(Duration(days: offset));
      if (candidate.year < 1 || candidate.isAfter(asOf)) {
        continue;
      }
      final calculated = AppDateUtils.calculateAge(candidate, asOf);
      if (calculated.years != years ||
          calculated.months != months ||
          calculated.days != days) {
        continue;
      }
      final result = DobFinderResult(
        birthDate: candidate,
        asOfDate: asOf,
        years: years,
        months: months,
        days: days,
      );
      if (best == null ||
          candidate.difference(center).inDays.abs() <
              best.birthDate.difference(center).inDays.abs() ||
          (candidate.difference(center).inDays.abs() ==
                  best.birthDate.difference(center).inDays.abs() &&
              candidate.isBefore(best.birthDate))) {
        best = result;
      }
    }
    return best;
  }
}
