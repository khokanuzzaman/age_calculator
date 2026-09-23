import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/notifications/notification_gateway_provider.dart';
import '../../life_timeline/providers/life_events_provider.dart';
import '../../life_timeline/models/life_event.dart';
import '../../profile/providers/primary_profile_provider.dart';
import '../models/birthday_reminder_time.dart';
import '../models/saved_person.dart';
import 'saved_birthdays_provider.dart';

/// Whether the user has enabled yearly birthday reminders.
final remindersEnabledProvider =
    NotifierProvider<RemindersEnabledNotifier, bool>(
      RemindersEnabledNotifier.new,
    );

final birthdayReminderTimeProvider = Provider<BirthdayReminderTime>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BirthdayReminderTime(
    hour:
        prefs.getInt(_birthdayReminderHourKey) ??
        BirthdayReminderTime.defaultTime.hour,
    minute:
        prefs.getInt(_birthdayReminderMinuteKey) ??
        BirthdayReminderTime.defaultTime.minute,
  ).normalized();
});

const _scheduleSchemaVersionKey = 'notification_schedule_schema_version';
const _scheduleSchemaVersion = 2;
const _birthdayReminderHourKey = 'birthday_reminder_time_hour';
const _birthdayReminderMinuteKey = 'birthday_reminder_time_minute';

class RemindersEnabledNotifier extends Notifier<bool> {
  static const _key = 'birthday_reminders_enabled';
  Future<bool>? _schemaMigration;
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
      final migrated = await ensureScheduleSchema();
      if (!migrated) {
        await _rescheduleEverything();
      }
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

  Future<void> syncPerson(SavedPerson person) async {
    if (!state) {
      return;
    }
    await ref
        .read(notificationGatewayProvider)
        .syncPerson(
          person,
          reminderTime: ref.read(birthdayReminderTimeProvider),
        );
  }

  Future<void> removePerson(String personId) async {
    if (!state) {
      return;
    }
    await ref.read(notificationGatewayProvider).cancelPersonReminders(personId);
  }

  Future<void> syncLifeEvent(LifeEvent event) async {
    if (!state) {
      return;
    }
    await ref
        .read(notificationGatewayProvider)
        .syncLifeEvent(
          event,
          reminderTime: ref.read(birthdayReminderTimeProvider),
        );
  }

  Future<void> removeLifeEvent(String eventId) async {
    if (!state) {
      return;
    }
    await ref
        .read(notificationGatewayProvider)
        .cancelLifeEventReminders(eventId);
  }

  Future<bool> ensureScheduleSchema() async {
    final running = _schemaMigration;
    if (running != null) {
      return running;
    }
    final migration = _runScheduleSchemaMigration();
    _schemaMigration = migration.whenComplete(() => _schemaMigration = null);
    return migration;
  }

  Future<bool> _runScheduleSchemaMigration() async {
    if (!state) {
      return false;
    }
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getInt(_scheduleSchemaVersionKey) == _scheduleSchemaVersion) {
      return false;
    }
    await _rescheduleEverything();
    await prefs.setInt(_scheduleSchemaVersionKey, _scheduleSchemaVersion);
    return true;
  }

  Future<void> setBirthdayReminderTime(BirthdayReminderTime time) async {
    final normalized = time.normalized();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_birthdayReminderHourKey, normalized.hour);
    await prefs.setInt(_birthdayReminderMinuteKey, normalized.minute);
    ref.invalidate(birthdayReminderTimeProvider);
    if (state) {
      await _rescheduleEverything();
    }
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

  /// Synchronizes the user's own reminders with the primary profile. The
  /// profile repository owns persistence; this method only schedules or
  /// cancels notification IDs.
  Future<void> setOwnBirthDate(DateTime? birthDate) async {
    if (!state) {
      return;
    }

    if (birthDate == null) {
      await ref.read(notificationGatewayProvider).cancelOwnReminders();
    } else {
      await ref
          .read(notificationGatewayProvider)
          .scheduleOwnBirthdayCountdown(
            birthDate,
            reminderTime: ref.read(birthdayReminderTimeProvider),
          );
      await ref
          .read(notificationGatewayProvider)
          .scheduleNextDayMilestone(
            birthDate,
            reminderTime: ref.read(birthdayReminderTimeProvider),
          );
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
          reminderTime: ref.read(birthdayReminderTimeProvider),
        );
    final ownDob = _readOwnBirthDate();
    if (ownDob != null) {
      await ref
          .read(notificationGatewayProvider)
          .scheduleOwnBirthdayCountdown(
            ownDob,
            reminderTime: ref.read(birthdayReminderTimeProvider),
          );
      await ref
          .read(notificationGatewayProvider)
          .scheduleNextDayMilestone(
            ownDob,
            reminderTime: ref.read(birthdayReminderTimeProvider),
          );
    }
  }

  DateTime? _readOwnBirthDate() {
    return ref.read(primaryProfileRepositoryProvider).load()?.birthDate;
  }
}
