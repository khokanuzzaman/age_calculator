import '../../../../core/utils/date_utils.dart';

class AgeDifferenceResult {
  const AgeDifferenceResult({
    required this.olderLabel,
    required this.youngerLabel,
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.totalMonths,
    required this.isSameAge,
  });

  final String olderLabel;
  final String youngerLabel;
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int totalMonths;
  final bool isSameAge;
}

class AgeDifferenceUtils {
  AgeDifferenceUtils._();

  static const String futureValidationMessage =
      'Date of birth cannot be in the future';

  static bool isValidBirthDate(DateTime date) {
    return !AppDateUtils.isAfterDay(date, DateTime.now());
  }

  static AgeDifferenceResult calculate({
    required DateTime personOneBirthDate,
    required DateTime personTwoBirthDate,
  }) {
    final personOne = AppDateUtils.dateOnly(personOneBirthDate);
    final personTwo = AppDateUtils.dateOnly(personTwoBirthDate);

    if (personOne.isAtSameMomentAs(personTwo)) {
      return const AgeDifferenceResult(
        olderLabel: 'Person 1',
        youngerLabel: 'Person 2',
        years: 0,
        months: 0,
        days: 0,
        totalDays: 0,
        totalMonths: 0,
        isSameAge: true,
      );
    }

    final personOneOlder = personOne.isBefore(personTwo);
    final older = personOneOlder ? personOne : personTwo;
    final younger = personOneOlder ? personTwo : personOne;
    final span = AppDateUtils.calculateAge(older, younger);

    return AgeDifferenceResult(
      olderLabel: personOneOlder ? 'Person 1' : 'Person 2',
      youngerLabel: personOneOlder ? 'Person 2' : 'Person 1',
      years: span.years,
      months: span.months,
      days: span.days,
      totalDays: span.totalDays,
      totalMonths: (span.years * 12) + span.months,
      isSameAge: false,
    );
  }
}
