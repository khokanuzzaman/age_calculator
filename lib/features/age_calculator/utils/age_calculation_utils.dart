import '../../../core/utils/date_utils.dart';
import '../models/age_milestone_model.dart';

class AgeCalculationUtils {
  AgeCalculationUtils._();

  static DateTime nextBirthday(DateTime birthDate, DateTime referenceDate) {
    final birth = AppDateUtils.dateOnly(birthDate);
    final reference = AppDateUtils.dateOnly(referenceDate);

    var candidate = _birthdayForYear(birth, reference.year);
    if (candidate.isBefore(reference)) {
      candidate = _birthdayForYear(birth, reference.year + 1);
    }
    return candidate;
  }

  static DateTime _birthdayForYear(DateTime birthDate, int year) {
    if (birthDate.month == 2 && birthDate.day == 29) {
      final isLeap = DateTime(year, 2, 29).day == 29;
      return DateTime(year, 2, isLeap ? 29 : 28);
    }
    return DateTime(year, birthDate.month, birthDate.day);
  }

  static BirthdayDetails birthdayDetails(DateTime birthDate, DateTime now) {
    final birth = AppDateUtils.dateOnly(birthDate);
    final today = AppDateUtils.dateOnly(now);
    final nextDate = nextBirthday(birth, today);

    return BirthdayDetails(
      bornWeekday: AppDateUtils.weekdayName(birth),
      nextBirthdayDate: nextDate,
      nextBirthdayWeekday: AppDateUtils.weekdayName(nextDate),
      daysUntilNextBirthday: nextDate.difference(today).inDays,
    );
  }

  static List<AgeMilestone> upcomingMilestones(
    DateTime birthDate,
    DateTime now,
  ) {
    final birth = AppDateUtils.dateOnly(birthDate);
    final today = AppDateUtils.dateOnly(now);

    final dayMilestones = [10000, 15000, 20000, 25000]
        .map(
          (days) => AgeMilestone(
            title: '${AppDateUtils.formatLargeInteger(days)} days old',
            targetDate: birth.add(Duration(days: days)),
            remainingDays: birth
                .add(Duration(days: days))
                .difference(today)
                .inDays,
          ),
        )
        .toList(growable: true);

    final billionSecondsDate = birth.add(const Duration(seconds: 1000000000));
    dayMilestones.add(
      AgeMilestone(
        title: '1 billion seconds old',
        targetDate: billionSecondsDate,
        remainingDays: billionSecondsDate.difference(today).inDays,
      ),
    );

    final nextBirthdayDate = nextBirthday(birth, today);
    dayMilestones.add(
      AgeMilestone(
        title: 'Next birthday',
        targetDate: nextBirthdayDate,
        remainingDays: nextBirthdayDate.difference(today).inDays,
      ),
    );

    final halfBirthdayDate = _nextHalfBirthday(birth, today);
    dayMilestones.add(
      AgeMilestone(
        title: 'Next half birthday',
        targetDate: halfBirthdayDate,
        remainingDays: halfBirthdayDate.difference(today).inDays,
      ),
    );

    final futureOnly = dayMilestones
        .where((m) => !m.targetDate.isBefore(today))
        .toList();
    futureOnly.sort((a, b) => a.targetDate.compareTo(b.targetDate));

    return futureOnly.take(5).toList(growable: false);
  }

  static DateTime _nextHalfBirthday(DateTime birth, DateTime today) {
    var candidate = _addMonthsSafe(birth, 6);
    while (candidate.isBefore(today)) {
      candidate = _addMonthsSafe(candidate, 12);
    }
    return candidate;
  }

  static DateTime _addMonthsSafe(DateTime date, int monthsToAdd) {
    final monthIndex = date.month - 1 + monthsToAdd;
    final year = date.year + (monthIndex ~/ 12);
    final month = (monthIndex % 12) + 1;
    final day = date.day.clamp(1, AppDateUtils.daysInMonth(year, month));
    return DateTime(year, month, day);
  }

  static LifeStats lifeStats(DateTime birthDate, DateTime now) {
    final birth = AppDateUtils.dateOnly(birthDate);
    final safeNow = now.isBefore(birth) ? birth : now;

    final livedDuration = safeNow.difference(birth);
    final totalDays = livedDuration.inDays;
    final totalHours = livedDuration.inHours;
    final totalMinutes = livedDuration.inMinutes;
    final totalSeconds = livedDuration.inSeconds;

    final yearStart = DateTime(safeNow.year, 1, 1);
    final nextYearStart = DateTime(safeNow.year + 1, 1, 1);
    final monthStart = DateTime(safeNow.year, safeNow.month, 1);
    final nextMonthStart = DateTime(safeNow.year, safeNow.month + 1, 1);
    final weekStart = DateTime(
      safeNow.year,
      safeNow.month,
      safeNow.day,
    ).subtract(Duration(days: safeNow.weekday - 1));
    final nextWeekStart = weekStart.add(const Duration(days: 7));

    return LifeStats(
      totalDays: totalDays,
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      totalSeconds: totalSeconds,
      yearProgress: _progress(yearStart, nextYearStart, safeNow),
      monthProgress: _progress(monthStart, nextMonthStart, safeNow),
      weekProgress: _progress(weekStart, nextWeekStart, safeNow),
    );
  }

  static double _progress(DateTime start, DateTime end, DateTime now) {
    final total = end.difference(start).inMilliseconds;
    final elapsed = now.difference(start).inMilliseconds;
    if (total <= 0) {
      return 0;
    }

    final ratio = elapsed / total;
    if (ratio.isNaN || ratio.isInfinite) {
      return 0;
    }

    return ratio.clamp(0, 1) * 100;
  }

  /// Pure display data for the home-screen widget. Reuses [AppDateUtils
  /// .calculateAge] for the age and days-until-next-birthday.
  static AgeWidgetData widgetData(DateTime birthDate, DateTime now) {
    final result = AppDateUtils.calculateAge(birthDate, now);
    final years = result.years;
    return AgeWidgetData(
      years: years,
      ageText: '$years ${years == 1 ? 'year' : 'years'}',
      daysUntilNextBirthday: result.daysUntilNextBirthday,
    );
  }

  /// The user's next round-number "days lived" milestone (next multiple of
  /// [step], e.g. 10000, 11000...). Today counts if it lands exactly on a
  /// milestone; otherwise the next future multiple is returned. A newborn's
  /// first milestone is [step].
  static DayMilestone nextDayMilestone(
    DateTime birthDate,
    DateTime now, {
    int step = 1000,
  }) {
    final birth = AppDateUtils.dateOnly(birthDate);
    final today = AppDateUtils.dateOnly(now);
    final lived = today.difference(birth).inDays;

    final int targetDays;
    if (lived < step) {
      targetDays = step;
    } else if (lived % step == 0) {
      targetDays = lived;
    } else {
      targetDays = ((lived ~/ step) + 1) * step;
    }

    return DayMilestone(
      days: targetDays,
      // Constructor arithmetic (not Duration) so the result stays at local
      // midnight and never drifts across DST boundaries.
      date: DateTime(birth.year, birth.month, birth.day + targetDays),
    );
  }

  /// Lead-time reminder dates before the user's next birthday. Reuses
  /// [nextBirthday] (which rolls over to next year once this year's has
  /// passed), so every returned date is on or before that upcoming birthday.
  static List<BirthdayLead> birthdayCountdownLeads(
    DateTime birthDate,
    DateTime now, {
    List<int> leadDays = const [7, 1, 0],
  }) {
    final today = AppDateUtils.dateOnly(now);
    final bday = nextBirthday(birthDate, today);
    return leadDays
        .map(
          (d) => BirthdayLead(
            daysBefore: d,
            date: DateTime(bday.year, bday.month, bday.day - d),
          ),
        )
        .toList(growable: false);
  }

  static String buildShareText({
    required int years,
    required int months,
    required int days,
    required int totalDays,
    required int daysUntilNextBirthday,
  }) {
    return 'I am $years years, $months months, and $days days old today.\n'
        'I have lived ${AppDateUtils.formatLargeInteger(totalDays)} days.\n'
        'My next birthday is in ${AppDateUtils.formatLargeInteger(daysUntilNextBirthday)} days.\n\n'
        'Calculated with Age Calculator.';
  }
}
