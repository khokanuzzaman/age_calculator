import 'package:age_calculator/core/analytics/app_analytics_provider.dart';
import 'package:age_calculator/features/age_calculator/application/age_calculator_notifier.dart';
import 'package:age_calculator/features/profile/data/primary_profile_repository.dart';
import 'package:age_calculator/features/profile/providers/primary_profile_provider.dart';
import 'package:age_calculator/app/theme/theme_mode_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_app_analytics.dart';

void main() {
  test('loads the existing primary birth date key without migration', () async {
    final birthDate = DateTime(1990, 1, 2);
    SharedPreferences.setMockInitialValues({
      PrimaryProfileRepository.birthDateKey: birthDate.millisecondsSinceEpoch,
      PrimaryProfileRepository.displayNameKey: '  Khokan  ',
      'saved_birthdays_v1': 'kept',
    });
    final prefs = await SharedPreferences.getInstance();

    final profile = PrimaryProfileRepository(prefs).load();

    expect(profile?.birthDate, birthDate);
    expect(profile?.displayName, 'Khokan');
    expect(prefs.getString('saved_birthdays_v1'), 'kept');
  });

  test(
    'generic calculator edits never overwrite the primary profile',
    () async {
      final profileDate = DateTime(1990, 1, 2);
      SharedPreferences.setMockInitialValues({
        PrimaryProfileRepository.birthDateKey:
            profileDate.millisecondsSinceEpoch,
      });
      final prefs = await SharedPreferences.getInstance();
      final analytics = FakeAppAnalytics();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appAnalyticsProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(primaryProfileProvider)?.birthDate, profileDate);
      container
          .read(ageCalculatorProvider.notifier)
          .setBirthDate(DateTime(2001, 4, 5));

      expect(
        container.read(ageCalculatorProvider).birthDate,
        DateTime(2001, 4, 5),
      );
      expect(container.read(primaryProfileProvider)?.birthDate, profileDate);
      expect(
        prefs.getInt(PrimaryProfileRepository.birthDateKey),
        profileDate.millisecondsSinceEpoch,
      );
    },
  );

  test('saving and clearing profile preserves unrelated local data', () async {
    SharedPreferences.setMockInitialValues({
      'saved_birthdays_v1': 'kept',
      'life_events_v1': 'kept',
    });
    final prefs = await SharedPreferences.getInstance();
    final analytics = FakeAppAnalytics();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appAnalyticsProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(primaryProfileProvider.notifier)
        .save(birthDate: DateTime(1988, 6, 7), displayName: 'Khokan');
    expect(analytics.events.single.event.name, 'primary_profile_saved');
    await container
        .read(primaryProfileProvider.notifier)
        .save(birthDate: DateTime(1988, 6, 8), displayName: 'Khokan');
    expect(analytics.events[1].event.name, 'primary_profile_updated');

    await container.read(primaryProfileProvider.notifier).clear();

    expect(container.read(primaryProfileProvider), isNull);
    expect(prefs.containsKey(PrimaryProfileRepository.birthDateKey), isFalse);
    expect(prefs.containsKey(PrimaryProfileRepository.displayNameKey), isFalse);
    expect(prefs.getString('saved_birthdays_v1'), 'kept');
    expect(prefs.getString('life_events_v1'), 'kept');
    expect(analytics.events.last.event.name, 'primary_profile_cleared');
    for (final event in analytics.events) {
      expect(event.parameters, isEmpty);
    }
  });
}
