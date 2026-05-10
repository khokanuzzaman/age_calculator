import '../../../../core/utils/date_utils.dart';

class LeapYearResult {
  const LeapYearResult({
    required this.year,
    required this.isLeapYear,
    required this.previousLeapYear,
    required this.nextLeapYear,
    required this.daysInFebruary,
  });

  final int year;
  final bool isLeapYear;
  final int? previousLeapYear;
  final int? nextLeapYear;
  final int daysInFebruary;
}

class LeapYearUtils {
  LeapYearUtils._();

  static bool isLeapYear(int year) {
    return AppDateUtils.isLeapYear(year);
  }

  static LeapYearResult calculate(int year) {
    return LeapYearResult(
      year: year,
      isLeapYear: isLeapYear(year),
      previousLeapYear: AppDateUtils.previousLeapYear(year),
      nextLeapYear: AppDateUtils.nextLeapYear(year),
      daysInFebruary: AppDateUtils.daysInFebruary(year),
    );
  }

  static String? validateYear(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Year is required';
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return 'Year must be numeric';
    }

    if (parsed < 1 || parsed > 9999) {
      return 'Year must be between 1 and 9999';
    }

    return null;
  }
}
