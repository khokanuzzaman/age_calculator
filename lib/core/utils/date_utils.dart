import 'package:intl/intl.dart';

import '../../features/age_calculator/domain/models/age_result.dart';

class AppDateUtils {
  AppDateUtils._();

  static AgeResult calculateAge(DateTime birthDate, DateTime asOfDate) {
    final birth = dateOnly(birthDate);
    final reference = dateOnly(asOfDate);

    if (birth.isAfter(reference)) {
      throw ArgumentError('Birth date cannot be after the reference date');
    }

    final years = _completedYears(birth, reference);
    final lastBirthday = _safeDate(birth.year + years, birth.month, birth.day);
    final monthAnchor = _completedMonthAnchor(lastBirthday, reference);
    final months = _monthDelta(lastBirthday, monthAnchor);
    final days = reference.difference(monthAnchor).inDays;
    final totalDays = reference.difference(birth).inDays;
    final totalHours = totalDays * 24;
    final totalMinutes = totalHours * 60;

    return AgeResult(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      daysUntilNextBirthday: daysUntilNextBirthday(
        birthDate: birth,
        asOfDate: reference,
      ),
      dayOfWeekBorn: weekdayName(birth),
      birthDate: birth,
      asOfDate: reference,
    );
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool isAfterDay(DateTime first, DateTime second) {
    return dateOnly(first).isAfter(dateOnly(second));
  }

  static int daysBetween(DateTime start, DateTime end) {
    return dateOnly(end).difference(dateOnly(start)).inDays;
  }

  static int daysUntilNextBirthday({
    required DateTime birthDate,
    required DateTime asOfDate,
  }) {
    final birth = dateOnly(birthDate);
    final reference = dateOnly(asOfDate);
    var nextBirthday = birthdayInYear(birth, reference.year);

    if (nextBirthday.isBefore(reference)) {
      nextBirthday = birthdayInYear(birth, reference.year + 1);
    }

    return nextBirthday.difference(reference).inDays;
  }

  static DateTime birthdayInYear(DateTime birthDate, int year) {
    return _safeDate(year, birthDate.month, birthDate.day);
  }

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static bool isLeapYear(int year) {
    if (year % 4 != 0) {
      return false;
    }

    if (year % 100 != 0) {
      return true;
    }

    return year % 400 == 0;
  }

  static int? previousLeapYear(int year) {
    if (year <= 1) {
      return null;
    }

    for (var candidate = year - 1; candidate >= 1; candidate--) {
      if (isLeapYear(candidate)) {
        return candidate;
      }
    }

    return null;
  }

  static int? nextLeapYear(int year) {
    if (year >= 9999) {
      return null;
    }

    for (var candidate = year + 1; candidate <= 9999; candidate++) {
      if (isLeapYear(candidate)) {
        return candidate;
      }
    }

    return null;
  }

  static int daysInFebruary(int year) {
    return isLeapYear(year) ? 29 : 28;
  }

  static String formatLargeInteger(int value) {
    return NumberFormat.decimalPattern('en').format(value);
  }

  static String weekdayName(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return weekdays[dateOnly(date).weekday - 1];
  }

  static int _completedYears(DateTime birthDate, DateTime asOfDate) {
    var years = asOfDate.year - birthDate.year;
    final anniversaryThisYear = birthdayInYear(birthDate, asOfDate.year);

    if (anniversaryThisYear.isAfter(asOfDate)) {
      years -= 1;
    }

    return years;
  }

  static DateTime _completedMonthAnchor(DateTime start, DateTime end) {
    var months = _monthDelta(start, end);
    var anchor = _addMonthsClamped(start, months);

    if (anchor.isAfter(end)) {
      months -= 1;
      anchor = _addMonthsClamped(start, months);
    }

    return anchor;
  }

  static int _monthDelta(DateTime start, DateTime end) {
    return ((end.year - start.year) * 12) + end.month - start.month;
  }

  static DateTime _addMonthsClamped(DateTime date, int months) {
    final monthIndex = date.month - 1 + months;
    final year = date.year + (monthIndex ~/ 12);
    final month = (monthIndex % 12) + 1;

    return _safeDate(year, month, date.day);
  }

  static DateTime _safeDate(int year, int month, int day) {
    final clampedDay = day.clamp(1, daysInMonth(year, month));
    return DateTime(year, month, clampedDay);
  }
}
