import '../../../core/utils/date_utils.dart';
import '../../age_calculator/domain/models/age_result.dart';
import '../models/life_event.dart';
import '../models/life_event_recurrence.dart';

class LifeEventOccurrence {
  const LifeEventOccurrence({
    required this.event,
    required this.occurrenceDate,
    required this.daysUntil,
    required this.anniversaryNumber,
  });

  final LifeEvent event;
  final DateTime occurrenceDate;
  final int daysUntil;
  final int anniversaryNumber;

  bool get isToday => daysUntil == 0;
}

class LifeEventDetails {
  const LifeEventDetails({
    required this.eventDate,
    required this.daysFromToday,
    required this.ageAtEvent,
    this.occurrenceDate,
    this.anniversaryNumber,
  });

  final DateTime eventDate;
  final int daysFromToday;
  final AgeResult? ageAtEvent;
  final DateTime? occurrenceDate;
  final int? anniversaryNumber;

  bool get isRecurring => anniversaryNumber != null;

  bool get isUpcoming => daysFromToday >= 0;
  bool get isToday => daysFromToday == 0;

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

    final occurrence = nextOccurrence(event, now: today);
    final daysFromToday = occurrence == null
        ? eventDate.difference(today).inDays
        : occurrence.daysUntil;

    return LifeEventDetails(
      eventDate: eventDate,
      daysFromToday: daysFromToday,
      ageAtEvent: ageAtEvent,
      occurrenceDate: occurrence?.occurrenceDate,
      anniversaryNumber: event.recurrence == LifeEventRecurrence.yearly
          ? occurrence?.anniversaryNumber
          : null,
    );
  }

  static LifeEventOccurrence? nextOccurrence(LifeEvent event, {DateTime? now}) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final original = AppDateUtils.dateOnly(event.eventDate);
    if (event.recurrence == LifeEventRecurrence.none) {
      if (original.isBefore(today)) {
        return null;
      }
      return LifeEventOccurrence(
        event: event,
        occurrenceDate: original,
        daysUntil: original.difference(today).inDays,
        anniversaryNumber: 0,
      );
    }

    if (original.isAfter(today)) {
      return LifeEventOccurrence(
        event: event,
        occurrenceDate: original,
        daysUntil: original.difference(today).inDays,
        anniversaryNumber: 0,
      );
    }

    var occurrence = AppDateUtils.birthdayInYear(original, today.year);
    var anniversaryNumber = occurrence.year - original.year;
    if (occurrence.isBefore(today)) {
      occurrence = AppDateUtils.birthdayInYear(original, today.year + 1);
      anniversaryNumber = occurrence.year - original.year;
    }
    return LifeEventOccurrence(
      event: event,
      occurrenceDate: occurrence,
      daysUntil: occurrence.difference(today).inDays,
      anniversaryNumber: anniversaryNumber,
    );
  }

  static List<LifeEvent> sortEvents(
    Iterable<LifeEvent> events, {
    DateTime? now,
  }) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final upcoming = events
        .where((event) => nextOccurrence(event, now: today) != null)
        .toList();
    final past = events
        .where((event) => nextOccurrence(event, now: today) == null)
        .toList();

    upcoming.sort(
      (a, b) => nextOccurrence(a, now: today)!.occurrenceDate.compareTo(
        nextOccurrence(b, now: today)!.occurrenceDate,
      ),
    );
    past.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return [...upcoming, ...past];
  }

  static LifeEvent? nextUpcoming(Iterable<LifeEvent> events, {DateTime? now}) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final sorted = sortEvents(events, now: today);
    for (final event in sorted) {
      if (nextOccurrence(event, now: today) != null) {
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
    final anniversaryLine = details.isRecurring
        ? '\n${anniversaryLabel(details.anniversaryNumber!)} anniversary'
        : '';
    return '${event.emoji} ${event.title}\n'
        '${details.relativeText}$anniversaryLine$ageLine\n\n'
        'Planned with Age Calculator.';
  }

  static String anniversaryLabel(int number) {
    final suffix = number % 100 >= 11 && number % 100 <= 13
        ? 'th'
        : switch (number % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };
    return '$number$suffix';
  }

  static AgeResult? durationSince(LifeEvent event, {DateTime? now}) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final original = AppDateUtils.dateOnly(event.eventDate);
    if (original.isAfter(today)) {
      return null;
    }
    return AppDateUtils.calculateAge(original, today);
  }
}
