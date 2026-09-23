import 'package:age_calculator/core/analytics/app_analytics_provider.dart';
import 'package:age_calculator/core/notifications/notification_gateway_provider.dart';
import 'package:age_calculator/core/notifications/notification_id_factory.dart';
import 'package:age_calculator/app/theme/theme_mode_notifier.dart';
import 'package:age_calculator/features/age_calculator/utils/age_calculation_utils.dart';
import 'package:age_calculator/features/age_difference/utils/age_difference_utils.dart';
import 'package:age_calculator/features/saved_birthdays/data/saved_birthdays_repository.dart';
import 'package:age_calculator/features/saved_birthdays/models/birthday_reminder_preferences.dart';
import 'package:age_calculator/features/saved_birthdays/models/birthday_reminder_time.dart';
import 'package:age_calculator/features/saved_birthdays/models/saved_person.dart';
import 'package:age_calculator/features/saved_birthdays/providers/reminders_provider.dart';
import 'package:age_calculator/features/saved_birthdays/providers/saved_birthdays_provider.dart';
import 'package:age_calculator/features/saved_birthdays/utils/birthday_reminder_utils.dart';
import 'package:age_calculator/features/saved_birthdays/utils/saved_people_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_app_analytics.dart';
import 'fakes/fake_notification_gateway.dart';

void main() {
  test('legacy and new SavedPerson JSON are both compatible', () async {
    SharedPreferences.setMockInitialValues({
      'saved_birthdays_v1':
          '[{"id":"mom","name":"Mom","birthDateMs":631152000000,"emoji":"🎂","relation":null}]',
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = SavedBirthdaysRepository(prefs);
    final legacy = repo.load().single;

    expect(legacy.isFavorite, isFalse);
    expect(legacy.reminderPreferences.enabled, isTrue);
    expect(legacy.reminderPreferences.leadDays, [0]);

    final updated = legacy.copyWith(
      relation: 'Family',
      isFavorite: true,
      reminderPreferences: const BirthdayReminderPreferences(
        enabled: true,
        leadDays: [30, 7, 0],
      ),
    );
    await repo.save([updated]);
    final roundTrip = repo.load().single;
    expect(roundTrip.relation, 'Family');
    expect(roundTrip.isFavorite, isTrue);
    expect(roundTrip.reminderPreferences.leadDays, [30, 7, 0]);
  });

  test('stable notification IDs are namespaced and lead-aware', () {
    final birthday0 = NotificationIdFactory.savedBirthday('person-1', 0);
    final birthday7 = NotificationIdFactory.savedBirthday('person-1', 7);

    expect(birthday0, NotificationIdFactory.savedBirthday('person-1', 0));
    expect(birthday0, isNot(birthday7));
    expect(birthday0, greaterThan(0));
    expect({
      birthday0,
      birthday7,
      NotificationIdFactory.ownBirthday(0),
      NotificationIdFactory.milestone,
      NotificationIdFactory.lifeEvent('event-1'),
    }, hasLength(5));
  });

  test('reminder lead dates skip stale leads and handle edge dates', () {
    final leads = BirthdayReminderUtils.applicableLeads(
      DateTime(2000, 1, 10),
      DateTime(2026, 1, 8),
      leadDays: BirthdayReminderPreferences.supportedLeadDays,
    );
    expect(leads.map((lead) => lead.daysBefore), [1, 0]);

    final tomorrow = BirthdayReminderUtils.applicableLeads(
      DateTime(2000, 1, 10),
      DateTime(2026, 1, 9),
      leadDays: const [1, 0],
    );
    expect(tomorrow.map((lead) => lead.daysBefore), [1, 0]);

    final today = BirthdayReminderUtils.applicableLeads(
      DateTime(2000, 1, 10),
      DateTime(2026, 1, 10),
      leadDays: const [1, 0],
    );
    expect(today.map((lead) => lead.daysBefore), [0]);

    final leap = AgeCalculationUtils.birthdayDetails(
      DateTime(2000, 2, 29),
      DateTime(2023, 3, 1),
    );
    expect(leap.nextBirthdayDate, DateTime(2024, 2, 29));
  });

  test(
    'filters people by name, relation, month, favorite, and next birthday',
    () {
      final people = [
        SavedPerson(
          id: 'later',
          name: 'Alex',
          relation: 'Friend',
          birthDate: DateTime(1990, 2, 20),
          isFavorite: true,
        ),
        SavedPerson(
          id: 'soon',
          name: 'Mom',
          relation: 'Family',
          birthDate: DateTime(1970, 1, 5),
        ),
      ];
      final now = DateTime(2026, 1, 1);

      expect(
        SavedPeopleUtils.filter(
          people,
          filter: SavedPeopleFilter.upcoming,
          now: now,
        ).map((person) => person.name),
        ['Mom', 'Alex'],
      );
      expect(
        SavedPeopleUtils.filter(
          people,
          filter: SavedPeopleFilter.favorites,
          now: now,
        ).single.name,
        'Alex',
      );
      expect(
        SavedPeopleUtils.filter(
          people,
          filter: SavedPeopleFilter.thisMonth,
          now: now,
        ).single.name,
        'Mom',
      );
      expect(
        SavedPeopleUtils.filter(
          people,
          filter: SavedPeopleFilter.all,
          query: 'family',
          now: now,
        ).single.name,
        'Mom',
      );
    },
  );

  test('detail age difference reuses the shared age difference utility', () {
    final difference = AgeDifferenceUtils.calculate(
      personOneBirthDate: DateTime(1990, 1, 1),
      personTwoBirthDate: DateTime(1993, 4, 2),
    );

    expect(difference.years, 3);
    expect(difference.months, 3);
    expect(difference.days, 1);
  });

  test(
    'person CRUD uses scoped reminder operations and migration is idempotent',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifications = FakeNotificationGateway();
      final analytics = FakeAppAnalytics();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationGatewayProvider.overrideWithValue(notifications),
          appAnalyticsProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);

      final reminders = container.read(remindersEnabledProvider.notifier);
      expect(await reminders.setEnabled(true), isTrue);
      expect(notifications.rescheduleAllCalls, 1);
      expect(await reminders.ensureScheduleSchema(), isFalse);
      expect(prefs.getInt('notification_schedule_schema_version'), 2);

      final people = container.read(savedBirthdaysProvider.notifier);
      final first = SavedPerson(
        id: 'first',
        name: 'Mom',
        birthDate: DateTime(1970, 1, 5),
      );
      final second = SavedPerson(
        id: 'second',
        name: 'Alex',
        birthDate: DateTime(1990, 2, 20),
      );
      await people.addOrUpdate(first);
      await people.addOrUpdate(second);
      expect(notifications.cancelAllCalls, 0);
      expect(notifications.syncPersonCalls, 2);

      await people.addOrUpdate(first.copyWith(isFavorite: true));
      expect(notifications.syncPersonCalls, 3);
      final favoriteEvent = analytics.events.last;
      expect(favoriteEvent.event.name, 'birthday_favorite_changed');
      expect(favoriteEvent.parameters, {'enabled': true});
      await people.addOrUpdate(
        second.copyWith(
          reminderPreferences: const BirthdayReminderPreferences(
            enabled: true,
            leadDays: [7, 1, 0],
          ),
        ),
      );
      final reminderEvent = analytics.events.last;
      expect(reminderEvent.event.name, 'birthday_reminder_preferences_changed');
      expect(reminderEvent.parameters, {'enabled': true, 'lead_count': 3});
      await people.remove('first');
      expect(notifications.cancelPersonCalls, 1);
      expect(notifications.cancelledPersonIds, ['first']);

      await reminders.setBirthdayReminderTime(
        const BirthdayReminderTime(hour: 10, minute: 30),
      );
      expect(notifications.rescheduleAllCalls, 2);
      expect(container.read(birthdayReminderTimeProvider).totalMinutes, 630);
      await reminders.setEnabled(false);
      await people.addOrUpdate(
        SavedPerson(
          id: 'disabled',
          name: 'Disabled',
          birthDate: DateTime(1995, 3, 3),
          reminderPreferences: const BirthdayReminderPreferences(
            enabled: false,
          ),
        ),
      );
      expect(notifications.syncPersonCalls, 4);
      expect(notifications.cancelAllCalls, 1);
      for (final event in analytics.events) {
        expect(event.parameters.keys, isNot(contains('name')));
        expect(event.parameters.keys, isNot(contains('birth_date')));
        expect(event.parameters.keys, isNot(contains('relation')));
        expect(event.parameters.keys, isNot(contains('person_id')));
      }
    },
  );
}
