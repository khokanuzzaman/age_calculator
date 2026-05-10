import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/age_calculator/utils/age_calculation_utils.dart';
import '../../features/saved_birthdays/models/saved_person.dart';

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
