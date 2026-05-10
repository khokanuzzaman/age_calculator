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
      await NotificationService.instance.rescheduleAll(
        ref.read(savedBirthdaysProvider),
      );
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
    await NotificationService.instance.rescheduleAll(
      ref.read(savedBirthdaysProvider),
    );
  }
}
