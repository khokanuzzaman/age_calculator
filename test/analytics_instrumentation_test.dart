import 'package:age_calculator/app/app.dart';
import 'package:age_calculator/app/theme/theme_mode_notifier.dart';
import 'package:age_calculator/core/analytics/analytics_classification.dart';
import 'package:age_calculator/core/analytics/analytics_event.dart';
import 'package:age_calculator/core/analytics/app_analytics_provider.dart';
import 'package:age_calculator/core/notifications/notification_gateway_provider.dart';
import 'package:age_calculator/features/age_calculator/application/age_calculator_notifier.dart';
import 'package:age_calculator/features/saved_birthdays/models/saved_person.dart';
import 'package:age_calculator/features/saved_birthdays/providers/reminders_provider.dart';
import 'package:age_calculator/features/saved_birthdays/providers/saved_birthdays_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_app_analytics.dart';
import 'fakes/fake_notification_gateway.dart';

void main() {
  testWidgets('app_open is logged once for one app instance', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final analytics = FakeAppAnalytics();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appAnalyticsProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    final app = UncontrolledProviderScope(
      container: container,
      child: const AgeCalculatorApp(),
    );
    await tester.pumpWidget(app);
    await tester.pumpWidget(app);

    expect(
      analytics.events.where(
        (record) => record.event == AnalyticsEvent.appOpen,
      ),
      hasLength(1),
    );
  });

  test('age groups use the documented anonymous boundaries', () {
    expect(AnalyticsClassification.ageGroup(17), 'under_18');
    expect(AnalyticsClassification.ageGroup(18), '18_24');
    expect(AnalyticsClassification.ageGroup(24), '18_24');
    expect(AnalyticsClassification.ageGroup(25), '25_34');
    expect(AnalyticsClassification.ageGroup(34), '25_34');
    expect(AnalyticsClassification.ageGroup(35), '35_44');
    expect(AnalyticsClassification.ageGroup(45), '45_54');
    expect(AnalyticsClassification.ageGroup(55), '55_64');
    expect(AnalyticsClassification.ageGroup(65), '65_plus');
  });

  test('successful age calculations log only coarse product parameters', () {
    final analytics = FakeAppAnalytics();
    final container = ProviderContainer(
      overrides: [appAnalyticsProvider.overrideWithValue(analytics)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(ageCalculatorProvider.notifier);
    notifier
      ..setBirthDate(DateTime(1995, 6, 15))
      ..setAsOfDate(DateTime(2026, 4, 20))
      ..calculate();

    expect(analytics.events.single.event, AnalyticsEvent.ageCalculated);
    expect(analytics.events.single.parameters, {
      'source': 'age_calculator',
      'is_custom_as_of_date': true,
      'result_age_group': '25_34',
    });
    expect(
      analytics.events.single.parameters.keys,
      isNot(contains('birth_date')),
    );
    expect(analytics.events.single.parameters.keys, isNot(contains('age')));
  });

  test(
    'birthday analytics distinguish new, updated, and deleted records',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final analytics = FakeAppAnalytics();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appAnalyticsProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(savedBirthdaysProvider.notifier);
      final person = SavedPerson(
        id: 'person-1',
        name: 'Mom',
        birthDate: DateTime(1970, 5, 4),
      );

      await notifier.addOrUpdate(person);
      await notifier.addOrUpdate(
        person.copyWith(name: 'Parent', relation: 'family'),
      );
      await notifier.remove(person.id);

      expect(analytics.events.map((record) => record.event), [
        AnalyticsEvent.birthdaySaved,
        AnalyticsEvent.birthdayUpdated,
        AnalyticsEvent.birthdayDeleted,
      ]);
      expect(analytics.events.first.parameters, {'has_relation': false});
      for (final record in analytics.events) {
        expect(record.parameters.keys, isNot(contains('name')));
        expect(record.parameters.keys, isNot(contains('birth_date')));
        expect(record.parameters.keys, isNot(contains('person_id')));
      }
    },
  );

  test('reminder analytics reflects permission and stored state', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final analytics = FakeAppAnalytics();
    final notifications = FakeNotificationGateway();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appAnalyticsProvider.overrideWithValue(analytics),
        notificationGatewayProvider.overrideWithValue(notifications),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(remindersEnabledProvider.notifier);
    expect(await notifier.setEnabled(true), isTrue);
    expect(container.read(remindersEnabledProvider), isTrue);
    expect(
      analytics.events.single.event,
      AnalyticsEvent.birthdayReminderEnabled,
    );
    expect(analytics.events.single.parameters, {
      'enabled': true,
      'permission_granted': true,
    });

    analytics.events.clear();
    expect(await notifier.setEnabled(false), isFalse);
    expect(container.read(remindersEnabledProvider), isFalse);
    expect(analytics.events.single.parameters, {'enabled': false});

    final deniedAnalytics = FakeAppAnalytics();
    final deniedNotifications = FakeNotificationGateway()
      ..permissionGranted = false;
    final deniedContainer = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appAnalyticsProvider.overrideWithValue(deniedAnalytics),
        notificationGatewayProvider.overrideWithValue(deniedNotifications),
      ],
    );
    addTearDown(deniedContainer.dispose);

    expect(
      await deniedContainer
          .read(remindersEnabledProvider.notifier)
          .setEnabled(true),
      isFalse,
    );
    expect(
      deniedAnalytics.events.single.event,
      AnalyticsEvent.notificationPermissionDenied,
    );
  });
}
