import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/age_calculator/utils/age_calculation_utils.dart';
import '../../features/saved_birthdays/models/saved_person.dart';
import '../utils/date_utils.dart';

/// Schedules yearly local notifications for saved birthdays.
///
/// Reminders fire at 9:00 AM on each person's birthday and repeat every year.
/// Scheduling is inexact (so no exact-alarm permission is required) — exact
/// timing is unnecessary for a birthday greeting.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'birthday_reminders';
  static const _channelName = 'Birthday Reminders';
  static const _channelDescription =
      'Yearly reminders for your saved birthdays';
  static const _reminderHour = 9;

  // Second channel for the user's OWN reminders (kept separate from the saved
  // people channel above, which stays untouched).
  static const _personalChannelId = 'personal_milestones';
  static const _personalChannelName = 'Personal Reminders';
  static const _personalChannelDescription =
      'Your birthday countdown and day-milestones';

  // Fixed, negative notification IDs for the user's own reminders. Saved-people
  // IDs are `hashCode & 0x7fffffff` (always >= 0), so negative IDs can never
  // collide with them.
  static const _ownBirthdayBaseId = -1000; // lead id = base - daysBefore
  static const _milestoneId = -2000;
  static const _ownBirthdayLeadDays = [7, 1, 0];

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    try {
      tz.initializeTimeZones();
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Fall back to UTC if the device timezone can't be resolved.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  /// Requests notification permission. Returns true if granted (or not required).
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true);
      return granted ?? true;
    }
    return true;
  }

  int _notificationId(String personId) => personId.hashCode & 0x7fffffff;

  Future<void> scheduleBirthday(SavedPerson person) async {
    await init();
    final scheduled = _nextBirthdayAt9am(person.birthDate);

    await _plugin.zonedSchedule(
      _notificationId(person.id),
      '🎂 ${person.name}\'s birthday!',
      'Wish ${person.name} a happy birthday today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelBirthday(String personId) async {
    await init();
    await _plugin.cancel(_notificationId(personId));
  }

  /// Cancels all reminders then reschedules the given people. Used when
  /// reminders are toggled on or the list changes.
  Future<void> rescheduleAll(List<SavedPerson> people) async {
    await init();
    await _plugin.cancelAll();
    for (final person in people) {
      await scheduleBirthday(person);
    }
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  // --- The user's OWN reminders (personal_milestones channel) ---

  /// Schedules a small set of lead-time reminders (7 days / 1 day / on the day)
  /// before the user's next birthday. Uses fixed negative IDs and repeats
  /// yearly, so it stays scheduled without needing the app to be reopened.
  Future<void> scheduleOwnBirthdayCountdown(DateTime birthDate) async {
    await init();
    // Clear previous leads first so a changed DOB doesn't leave stale dates.
    for (final d in _ownBirthdayLeadDays) {
      await _plugin.cancel(_ownBirthdayBaseId - d);
    }

    final now = tz.TZDateTime.now(tz.local);
    final leads = AgeCalculationUtils.birthdayCountdownLeads(
      birthDate,
      DateTime(now.year, now.month, now.day),
      leadDays: _ownBirthdayLeadDays,
    );

    for (final lead in leads) {
      final body = switch (lead.daysBefore) {
        0 => 'It\'s your birthday today! 🎂',
        1 => 'Your birthday is tomorrow 🎉',
        _ => 'Your birthday is in ${lead.daysBefore} days 🎉',
      };
      await _plugin.zonedSchedule(
        _ownBirthdayBaseId - lead.daysBefore,
        '🎂 Your birthday',
        body,
        _at9am(lead.date),
        _personalDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Yearly: past leads roll forward to next year automatically.
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  /// Schedules a one-time reminder for the user's next round-number
  /// "days lived" milestone (e.g. 10,000 days).
  Future<void> scheduleNextDayMilestone(DateTime birthDate) async {
    await init();
    await _plugin.cancel(_milestoneId);

    final now = tz.TZDateTime.now(tz.local);
    final milestone = AgeCalculationUtils.nextDayMilestone(
      birthDate,
      DateTime(now.year, now.month, now.day),
    );
    final scheduled = _at9am(milestone.date);
    if (!scheduled.isAfter(now)) {
      // Today's milestone time has already passed; the next one gets scheduled
      // the next time reminders are re-synced.
      return;
    }

    final formatted = AppDateUtils.formatLargeInteger(milestone.days);
    await _plugin.zonedSchedule(
      _milestoneId,
      '🎂 $formatted days old!',
      'You\'re $formatted days old today. What a milestone!',
      scheduled,
      _personalDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // One-shot: a given days-milestone happens exactly once.
    );
  }

  /// Cancels the user's own birthday-countdown and milestone reminders.
  Future<void> cancelOwnReminders() async {
    await init();
    for (final d in _ownBirthdayLeadDays) {
      await _plugin.cancel(_ownBirthdayBaseId - d);
    }
    await _plugin.cancel(_milestoneId);
  }

  NotificationDetails _personalDetails() => const NotificationDetails(
    android: AndroidNotificationDetails(
      _personalChannelId,
      _personalChannelName,
      channelDescription: _personalChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  tz.TZDateTime _at9am(DateTime date) {
    return tz.TZDateTime(tz.local, date.year, date.month, date.day, _reminderHour);
  }

  tz.TZDateTime _nextBirthdayAt9am(DateTime birthDate) {
    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime(now.year, now.month, now.day);
    final next = AgeCalculationUtils.nextBirthday(birthDate, today);
    return tz.TZDateTime(
      tz.local,
      next.year,
      next.month,
      next.day,
      _reminderHour,
    );
  }
}
