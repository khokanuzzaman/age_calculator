import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/engagement/engagement_action.dart';
import '../../../core/engagement/engagement_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../data/saved_birthdays_repository.dart';
import '../models/saved_person.dart';
import 'reminders_provider.dart';

final savedBirthdaysRepositoryProvider = Provider<SavedBirthdaysRepository>((
  ref,
) {
  return SavedBirthdaysRepository(ref.watch(sharedPreferencesProvider));
});

final savedBirthdaysProvider =
    NotifierProvider<SavedBirthdaysNotifier, List<SavedPerson>>(
      SavedBirthdaysNotifier.new,
    );

class SavedBirthdaysNotifier extends Notifier<List<SavedPerson>> {
  @override
  List<SavedPerson> build() {
    final people = ref.read(savedBirthdaysRepositoryProvider).load();
    return _sorted(people);
  }

  Future<void> addOrUpdate(SavedPerson person) async {
    final next = [...state];
    final index = next.indexWhere((p) => p.id == person.id);
    final isUpdate = index >= 0;
    final previous = isUpdate ? next[index] : null;
    if (index >= 0) {
      next[index] = person;
    } else {
      next.add(person);
    }
    final sorted = _sorted(next);
    await _persist(sorted);
    try {
      await ref.read(remindersEnabledProvider.notifier).syncPerson(person);
    } catch (_) {
      // Reminder sync is best-effort; never block a local save.
    }
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          isUpdate
              ? AnalyticsEvent.birthdayUpdated
              : AnalyticsEvent.birthdaySaved,
          parameters: isUpdate
              ? const <String, Object>{}
              : <String, Object>{
                  'has_relation': person.relation?.trim().isNotEmpty == true,
                },
        );
    if (!isUpdate) {
      try {
        ref
            .read(engagementTrackerProvider)
            .recordMeaningfulActionSafely(EngagementAction.people);
      } catch (_) {
        // Engagement tracking is optional and never blocks a local save.
      }
    }
    if (previous != null && previous.isFavorite != person.isFavorite) {
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.birthdayFavoriteChanged,
            parameters: <String, Object>{'enabled': person.isFavorite},
          );
    }
    if (previous != null &&
        previous.reminderPreferences != person.reminderPreferences) {
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.birthdayReminderPreferencesChanged,
            parameters: <String, Object>{
              'enabled': person.reminderPreferences.enabled,
              'lead_count': person.reminderPreferences.leadDays.length,
            },
          );
    }
  }

  Future<void> remove(String id) async {
    final existed = state.any((person) => person.id == id);
    if (!existed) {
      return;
    }
    final next = state.where((p) => p.id != id).toList(growable: false);
    await _persist(next);
    try {
      await ref.read(remindersEnabledProvider.notifier).removePerson(id);
    } catch (_) {
      // Reminder cancellation is best-effort; the local delete already won.
    }
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(AnalyticsEvent.birthdayDeleted);
  }

  Future<void> toggleFavorite(String id) async {
    final person = state.firstWhere((item) => item.id == id);
    await addOrUpdate(person.copyWith(isFavorite: !person.isFavorite));
  }

  Future<void> _persist(List<SavedPerson> people) async {
    state = people;
    await ref.read(savedBirthdaysRepositoryProvider).save(people);
  }

  /// Sort by who has a birthday coming up soonest.
  List<SavedPerson> _sorted(List<SavedPerson> people) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final sorted = [...people];
    sorted.sort((a, b) {
      final da = AgeCalculationUtils.birthdayDetails(
        a.birthDate,
        today,
      ).daysUntilNextBirthday;
      final db = AgeCalculationUtils.birthdayDetails(
        b.birthDate,
        today,
      ).daysUntilNextBirthday;
      return da.compareTo(db);
    });
    return sorted;
  }
}
