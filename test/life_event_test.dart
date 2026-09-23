import 'package:age_calculator/features/life_timeline/data/life_events_repository.dart';
import 'package:age_calculator/features/life_timeline/models/life_event.dart';
import 'package:age_calculator/features/life_timeline/utils/life_event_utils.dart';
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
}
