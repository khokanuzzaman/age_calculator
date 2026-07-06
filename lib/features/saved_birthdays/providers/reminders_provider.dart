import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/notifications/notification_service.dart';
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

    if (enabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        await prefs.setBool(_key, false);
        state = false;
        return false;
      }
      await prefs.setBool(_key, true);
      state = true;
      await _rescheduleEverything();
      return true;
    }

    await prefs.setBool(_key, false);
    state = false;
    await NotificationService.instance.cancelAll();
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
      await NotificationService.instance.cancelOwnReminders();
    } else {
      await NotificationService.instance.scheduleOwnBirthdayCountdown(birthDate);
      await NotificationService.instance.scheduleNextDayMilestone(birthDate);
    }
  }

  /// Reschedules saved-people birthdays and, since `rescheduleAll` clears
  /// everything first, re-adds the user's own reminders from the stored DOB.
  Future<void> _rescheduleEverything() async {
    await NotificationService.instance.rescheduleAll(
      ref.read(savedBirthdaysProvider),
    );
    final ownDob = _readOwnBirthDate();
    if (ownDob != null) {
      await NotificationService.instance.scheduleOwnBirthdayCountdown(ownDob);
      await NotificationService.instance.scheduleNextDayMilestone(ownDob);
    }
  }

  DateTime? _readOwnBirthDate() {
    final ms = ref.read(sharedPreferencesProvider).getInt(_ownDobKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
