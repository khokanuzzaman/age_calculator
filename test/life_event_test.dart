import 'package:age_calculator/features/life_timeline/data/life_events_repository.dart';
import 'package:age_calculator/features/life_timeline/models/life_event.dart';
import 'package:age_calculator/features/life_timeline/models/life_event_category.dart';
import 'package:age_calculator/features/life_timeline/models/life_event_recurrence.dart';
import 'package:age_calculator/features/life_timeline/models/life_event_reminder_preferences.dart';
import 'package:age_calculator/features/life_timeline/utils/life_event_utils.dart';
import 'package:age_calculator/features/life_timeline/utils/life_event_reminder_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('calculates future event age and countdown', () {
    final event = LifeEvent(
      id: 'graduation',
      title: 'Graduation',
      eventDate: DateTime(2026, 4, 15),
    );

    final details = LifeEventUtils.details(
      event,
      now: DateTime(2026, 4, 1),
      birthDate: DateTime(1995, 6, 3),
    );

    expect(details.daysFromToday, 14);
    expect(details.relativeText, 'In 14 days');
    expect(details.ageAtEvent?.years, 30);
    expect(details.ageAtEvent?.months, 10);
    expect(details.ageAtEvent?.days, 12);
    expect(details.ageText, 'You will be 30 years, 10 months, 12 days old');
  });

  test('handles past events and event dates before birth', () {
    final past = LifeEvent(
      id: 'first-job',
      title: 'First job',
      eventDate: DateTime(2020, 1, 1),
    );
    final beforeBirth = LifeEvent(
      id: 'before-birth',
      title: 'Before birth',
      eventDate: DateTime(1990, 1, 1),
    );

    final pastDetails = LifeEventUtils.details(
      past,
      now: DateTime(2026, 1, 1),
      birthDate: DateTime(1995, 6, 3),
    );
    final beforeBirthDetails = LifeEventUtils.details(
      beforeBirth,
      now: DateTime(2026, 1, 1),
      birthDate: DateTime(1995, 6, 3),
    );

    expect(pastDetails.relativeText, '2,192 days ago');
    expect(pastDetails.ageText, 'You were 24 years, 6 months, 29 days old');
    expect(beforeBirthDetails.ageAtEvent, isNull);
    expect(beforeBirthDetails.ageText, 'Set your birthday to see your age');
  });

  test('sorts upcoming events before past events', () {
    final events = [
      LifeEvent(id: 'past', title: 'Past', eventDate: DateTime(2025, 1, 1)),
      LifeEvent(id: 'later', title: 'Later', eventDate: DateTime(2026, 12, 1)),
      LifeEvent(id: 'soon', title: 'Soon', eventDate: DateTime(2026, 2, 1)),
    ];

    final sorted = LifeEventUtils.sortEvents(events, now: DateTime(2026, 1, 1));

    expect(sorted.map((event) => event.id), ['soon', 'later', 'past']);
    expect(
      LifeEventUtils.nextUpcoming(sorted, now: DateTime(2026, 1, 1))?.id,
      'soon',
    );
    expect(
      LifeEventUtils.nextUpcoming([events.first], now: DateTime(2026, 1, 1)),
      isNull,
    );
  });

  test('round-trips life events through SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = LifeEventsRepository(prefs);
    final event = LifeEvent(
      id: 'trip',
      title: 'Trip',
      eventDate: DateTime(2027, 5, 20),
      emoji: '✈️',
      reminderEnabled: false,
    );

    await repository.save([event]);
    final loaded = repository.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, event.id);
    expect(loaded.single.title, event.title);
    expect(loaded.single.eventDate, event.eventDate);
    expect(loaded.single.emoji, event.emoji);
    expect(loaded.single.reminderEnabled, isFalse);
  });

  test('legacy JSON defaults category and recurrence safely', () {
    final event = LifeEvent.fromJson({
      'id': 'legacy',
      'title': 'Legacy moment',
      'eventDateMs': DateTime(2020, 5, 9).millisecondsSinceEpoch,
      'emoji': '⭐',
      'reminderEnabled': true,
    });

    expect(event.category, LifeEventCategory.personal);
    expect(event.recurrence, LifeEventRecurrence.none);
    expect(event.reminderLeadDays, [0]);
  });

  test('yearly event and reminder preferences round-trip', () {
    final original = LifeEvent(
      id: 'wedding',
      title: 'Wedding',
      eventDate: DateTime(2019, 5, 9),
      category: LifeEventCategory.relationship,
      recurrence: LifeEventRecurrence.yearly,
      reminderPreferences: const LifeEventReminderPreferences(
        enabled: true,
        leadDays: [7, 1, 0],
      ),
    );

    final loaded = LifeEvent.fromJson(original.toJson());

    expect(loaded.category, LifeEventCategory.relationship);
    expect(loaded.recurrence, LifeEventRecurrence.yearly);
    expect(loaded.reminderPreferences, original.reminderPreferences);
    expect(loaded.eventDate, DateTime(2019, 5, 9));
  });

  test(
    'yearly occurrence derives current anniversary without mutating source',
    () {
      final event = LifeEvent(
        id: 'wedding',
        title: 'Wedding',
        eventDate: DateTime(2019, 5, 9),
        recurrence: LifeEventRecurrence.yearly,
      );

      final occurrence = LifeEventUtils.nextOccurrence(
        event,
        now: DateTime(2027, 5, 1),
      );

      expect(occurrence?.occurrenceDate, DateTime(2027, 5, 9));
      expect(occurrence?.daysUntil, 8);
      expect(occurrence?.anniversaryNumber, 8);
      expect(event.eventDate, DateTime(2019, 5, 9));
    },
  );

  test('yearly occurrence rolls to next year after this anniversary', () {
    final event = LifeEvent(
      id: 'wedding',
      title: 'Wedding',
      eventDate: DateTime(2019, 5, 9),
      recurrence: LifeEventRecurrence.yearly,
    );

    final occurrence = LifeEventUtils.nextOccurrence(
      event,
      now: DateTime(2027, 5, 10),
    );

    expect(occurrence?.occurrenceDate, DateTime(2028, 5, 9));
    expect(occurrence?.anniversaryNumber, 9);
  });

  test('yearly occurrence is today on the anniversary', () {
    final event = LifeEvent(
      id: 'wedding',
      title: 'Wedding',
      eventDate: DateTime(2019, 5, 9),
      recurrence: LifeEventRecurrence.yearly,
    );

    final occurrence = LifeEventUtils.nextOccurrence(
      event,
      now: DateTime(2027, 5, 9),
    );

    expect(occurrence?.isToday, isTrue);
    expect(occurrence?.anniversaryNumber, 8);
  });

  test('Feb 29 yearly events use the established Feb 28 fallback', () {
    final event = LifeEvent(
      id: 'leap-moment',
      title: 'Leap moment',
      eventDate: DateTime(2020, 2, 29),
      recurrence: LifeEventRecurrence.yearly,
    );

    final nonLeap = LifeEventUtils.nextOccurrence(
      event,
      now: DateTime(2023, 2, 1),
    );
    final leap = LifeEventUtils.nextOccurrence(
      event,
      now: DateTime(2024, 2, 1),
    );

    expect(nonLeap?.occurrenceDate, DateTime(2023, 2, 28));
    expect(leap?.occurrenceDate, DateTime(2024, 2, 29));
  });

  test('reminder preferences normalize one-time and yearly leads', () {
    const preferences = LifeEventReminderPreferences(
      enabled: true,
      leadDays: [3, 7, 1, 0, 7],
    );

    expect(preferences.normalized(recurring: false), [0]);
    expect(preferences.normalized(recurring: true), [7, 1, 0]);
  });

  test('yearly reminder schedules skip stale leads and keep future leads', () {
    final event = LifeEvent(
      id: 'wedding',
      title: 'Wedding',
      eventDate: DateTime(2019, 5, 9),
      recurrence: LifeEventRecurrence.yearly,
      reminderPreferences: const LifeEventReminderPreferences(
        leadDays: [7, 1, 0],
      ),
    );

    final schedules = LifeEventReminderUtils.upcomingSchedules(
      event,
      now: DateTime(2027, 5, 8),
    );

    expect(schedules.map((item) => item.leadDays), [1, 0]);
    expect(schedules.map((item) => item.scheduledDate), [
      DateTime(2027, 5, 8),
      DateTime(2027, 5, 9),
    ]);
  });

  test('disabled and past one-time events schedule nothing', () {
    final disabled = LifeEvent(
      id: 'disabled',
      title: 'Disabled',
      eventDate: DateTime(2027, 5, 9),
      reminderEnabled: false,
    );
    final past = LifeEvent(
      id: 'past',
      title: 'Past',
      eventDate: DateTime(2020, 5, 9),
    );

    expect(
      LifeEventReminderUtils.upcomingSchedules(
        disabled,
        now: DateTime(2027, 5, 1),
      ),
      isEmpty,
    );
    expect(
      LifeEventReminderUtils.upcomingSchedules(past, now: DateTime(2027, 5, 1)),
      isEmpty,
    );
  });
}
