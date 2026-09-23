import '../../../core/utils/date_utils.dart';
import '../../age_calculator/domain/models/age_result.dart';
import '../models/life_event.dart';

class LifeEventDetails {
  const LifeEventDetails({
    required this.eventDate,
    required this.daysFromToday,
    required this.ageAtEvent,
  });

  final DateTime eventDate;
  final int daysFromToday;
  final AgeResult? ageAtEvent;

  bool get isUpcoming => daysFromToday >= 0;

  String get relativeText {
    if (daysFromToday == 0) {
      return 'Today';
    }
    final days = AppDateUtils.formatLargeInteger(daysFromToday.abs());
    return daysFromToday > 0 ? 'In $days days' : '$days days ago';
  }

  String get ageText {
    final age = ageAtEvent;
    if (age == null) {
      return 'Set your birthday to see your age';
    }
    final value = '${age.years} years, ${age.months} months, ${age.days} days';
    if (daysFromToday == 0) {
      return 'You are $value old today';
    }
    return isUpcoming ? 'You will be $value old' : 'You were $value old';
  }
}

class LifeEventUtils {
  LifeEventUtils._();

  static LifeEventDetails details(
    LifeEvent event, {
    DateTime? now,
    DateTime? birthDate,
  }) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final eventDate = AppDateUtils.dateOnly(event.eventDate);
    final normalizedBirthDate = birthDate == null
        ? null
        : AppDateUtils.dateOnly(birthDate);
    final ageAtEvent =
        normalizedBirthDate != null && !eventDate.isBefore(normalizedBirthDate)
        ? AppDateUtils.calculateAge(normalizedBirthDate, eventDate)
        : null;

    return LifeEventDetails(
      eventDate: eventDate,
      daysFromToday: eventDate.difference(today).inDays,
      ageAtEvent: ageAtEvent,
    );
  }

  static List<LifeEvent> sortEvents(
    Iterable<LifeEvent> events, {
    DateTime? now,
  }) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final upcoming = events
        .where(
          (event) => !AppDateUtils.dateOnly(event.eventDate).isBefore(today),
        )
        .toList();
    final past = events
        .where(
          (event) => AppDateUtils.dateOnly(event.eventDate).isBefore(today),
        )
        .toList();

    upcoming.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    past.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return [...upcoming, ...past];
  }

  static LifeEvent? nextUpcoming(Iterable<LifeEvent> events, {DateTime? now}) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final sorted = sortEvents(events, now: today);
    for (final event in sorted) {
      if (!AppDateUtils.dateOnly(event.eventDate).isBefore(today)) {
        return event;
      }
    }
    return null;
  }

  static String buildShareText({
    required LifeEvent event,
    required LifeEventDetails details,
  }) {
    final age = details.ageAtEvent;
    final ageLine = age == null
        ? ''
        : '\n${details.isUpcoming ? 'I will be' : 'I was'} '
              '${age.years} years, ${age.months} months, and ${age.days} days old.';
    return '${event.emoji} ${event.title}\n'
        '${details.relativeText}$ageLine\n\n'
        'Planned with Age Calculator.';
  }
}
