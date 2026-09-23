import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/notifications/notification_gateway_provider.dart';
import '../../life_timeline/providers/life_events_provider.dart';
import 'saved_birthdays_provider.dart';

/// Whether the user has enabled yearly birthday reminders.
final remindersEnabledProvider =
    NotifierProvider<RemindersEnabledNotifier, bool>(
      RemindersEnabledNotifier.new,
    );

class RemindersEnabledNotifier extends Notifier<bool> {
  static const _key = 'birthday_reminders_enabled';
  static const _ownDobKey = 'primary_birth_date_ms';

  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  /// Enables or disables reminders. When enabling, requests notification
  /// permission first; returns the resulting enabled state.
  Future<bool> setEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final notifications = ref.read(notificationGatewayProvider);

    if (enabled) {
      final granted = await notifications.requestPermission();
      if (!granted) {
        await prefs.setBool(_key, false);
        state = false;
        ref
            .read(appAnalyticsProvider)
            .logEventSafely(
              AnalyticsEvent.notificationPermissionDenied,
              parameters: const <String, Object>{'permission_granted': false},
            );
        return false;
      }
      await prefs.setBool(_key, true);
      state = true;
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.birthdayReminderEnabled,
            parameters: const <String, Object>{
              'enabled': true,
              'permission_granted': true,
            },
          );
      await _rescheduleEverything();
      return true;
    }

    await prefs.setBool(_key, false);
    state = false;
    await notifications.cancelAll();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.birthdayReminderEnabled,
          parameters: const <String, Object>{'enabled': false},
        );
    return false;
  }

  /// Re-syncs scheduled reminders with the current saved list (called after the
  /// list changes). No-op when reminders are disabled.
  Future<void> syncFromSavedList() async {
    if (!state) {
      return;
    }
    await _rescheduleEverything();
  }

  /// Re-syncs all reminders after a life event changes.
  Future<void> syncFromLifeEvents() async {
    if (!state) {
      return;
    }
    try {
      await _rescheduleEverything();
    } catch (_) {
      // Reminder sync is best-effort; never block a life event save on it.
    }
  }

  /// Persists the user's own primary birth date and, when reminders are on,
  /// (re)schedules their birthday countdown and next day-milestone. Called
  /// whenever the primary birth date is set or changed. Gated by the reminders
  /// toggle — a no-op when reminders are off.
  Future<void> setOwnBirthDate(DateTime? birthDate) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (birthDate == null) {
      await prefs.remove(_ownDobKey);
    } else {
      await prefs.setInt(_ownDobKey, birthDate.millisecondsSinceEpoch);
    }

    if (!state) {
      return;
    }

    if (birthDate == null) {
      await ref.read(notificationGatewayProvider).cancelOwnReminders();
    } else {
      await ref
          .read(notificationGatewayProvider)
          .scheduleOwnBirthdayCountdown(birthDate);
      await ref
          .read(notificationGatewayProvider)
          .scheduleNextDayMilestone(birthDate);
    }
  }

  /// Reschedules saved-people birthdays and, since `rescheduleAll` clears
  /// everything first, re-adds the user's own reminders from the stored DOB.
  Future<void> _rescheduleEverything() async {
    await ref
        .read(notificationGatewayProvider)
        .rescheduleAll(
          ref.read(savedBirthdaysProvider),
          events: ref.read(lifeEventsProvider),
        );
    final ownDob = _readOwnBirthDate();
    if (ownDob != null) {
      await ref
          .read(notificationGatewayProvider)
          .scheduleOwnBirthdayCountdown(ownDob);
      await ref
          .read(notificationGatewayProvider)
          .scheduleNextDayMilestone(ownDob);
    }
  }

  DateTime? _readOwnBirthDate() {
    final ms = ref.read(sharedPreferencesProvider).getInt(_ownDobKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
