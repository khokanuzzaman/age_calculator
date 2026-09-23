import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/age_calculator/utils/age_calculation_utils.dart';
import '../../features/life_timeline/models/life_event.dart';
import '../../features/saved_birthdays/models/birthday_reminder_preferences.dart';
import '../../features/saved_birthdays/models/birthday_reminder_time.dart';
import '../../features/saved_birthdays/models/saved_person.dart';
import '../utils/date_utils.dart';
import 'notification_gateway.dart';
import 'notification_destination.dart';
import 'notification_id_factory.dart';
import 'notification_navigation_coordinator.dart';

/// Schedules yearly local notifications for saved birthdays.
///
/// Reminders fire at the user's configured local time and repeat every year.
/// Scheduling is inexact (so no exact-alarm permission is required) — exact
/// timing is unnecessary for a birthday greeting.
class NotificationService implements NotificationGateway {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'birthday_reminders';
  static const _channelName = 'Birthday Reminders';
  static const _channelDescription =
      'Yearly reminders for your saved birthdays';

  // Second channel for the user's OWN reminders (kept separate from the saved
  // people channel above, which stays untouched).
  static const _personalChannelId = 'personal_milestones';
  static const _personalChannelName = 'Personal Reminders';
  static const _personalChannelDescription =
      'Your birthday countdown and day-milestones';

  // Fixed, negative notification IDs for the user's own reminders. Saved-person
  // IDs use a separate positive namespace, so categories cannot collide.
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
    // Don't auto-prompt on init — permission is requested contextually via
    // [requestPermission] when the user opts into reminders, so it never
    // races the iOS App Tracking Transparency dialog shown at launch.
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    _initialized = true;
    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true) {
        NotificationNavigationCoordinator.instance.handlePayload(
          launchDetails?.notificationResponse?.payload,
        );
      }
    } catch (_) {
      // A notification launch is optional; startup must remain safe.
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    NotificationNavigationCoordinator.instance.handlePayload(response.payload);
  }

  /// Requests notification permission. Returns true if granted (or not required).
  @override
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

  int _lifeEventNotificationId(String eventId) {
    return NotificationIdFactory.lifeEvent(eventId);
  }

  Future<void> scheduleBirthday(
    SavedPerson person, {
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {
    await init();
    if (!person.reminderPreferences.enabled) {
      return;
    }
    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime(now.year, now.month, now.day);
    final leads = AgeCalculationUtils.birthdayCountdownLeads(
      person.birthDate,
      today,
      leadDays: person.reminderPreferences.leadDays,
    );

    for (final lead in leads) {
      final scheduled = _atTime(lead.date, reminderTime);
      if (!scheduled.isAfter(now)) {
        continue;
      }
      final copy = _birthdayCopy(person, lead.daysBefore);
      await _plugin.zonedSchedule(
        NotificationIdFactory.savedBirthday(person.id, lead.daysBefore),
        copy.title,
        copy.body,
        scheduled,
        _birthdayDetails(),
        payload: NotificationDestinationCodec.encode(
          NotificationDestination.person(person.id),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  Future<void> cancelBirthday(String personId) async {
    await cancelPersonReminders(personId);
  }

  @override
  Future<void> syncPerson(
    SavedPerson person, {
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {
    await cancelPersonReminders(person.id);
    await scheduleBirthday(person, reminderTime: reminderTime);
  }

  @override
  Future<void> cancelPersonReminders(String personId) async {
    await init();
    for (final leadDay in BirthdayReminderPreferences.supportedLeadDays) {
      await _plugin.cancel(
        NotificationIdFactory.savedBirthday(personId, leadDay),
      );
    }
  }

  Future<void> scheduleLifeEvent(
    LifeEvent event, {
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {
    await init();
    if (!event.reminderEnabled) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = _atTime(event.eventDate, reminderTime);
    if (!scheduled.isAfter(now)) {
      return;
    }

    await _plugin.zonedSchedule(
      _lifeEventNotificationId(event.id),
      '${event.emoji} ${event.title}',
      'Your life event is today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _personalChannelId,
          _personalChannelName,
          channelDescription: _personalChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: NotificationDestinationCodec.encode(
        const NotificationDestination.lifeTimeline(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels all reminders then reschedules the given people. Used when
  /// reminders are toggled on or the list changes.
  @override
  Future<void> rescheduleAll(
    List<SavedPerson> people, {
    List<LifeEvent> events = const [],
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {
    await init();
    await _plugin.cancelAll();
    for (final person in people) {
      await scheduleBirthday(person, reminderTime: reminderTime);
    }
    for (final event in events) {
      await scheduleLifeEvent(event, reminderTime: reminderTime);
    }
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  // --- The user's OWN reminders (personal_milestones channel) ---

  /// Schedules a small set of lead-time reminders (7 days / 1 day / on the day)
  /// before the user's next birthday. Uses fixed negative IDs and repeats
  /// yearly, so it stays scheduled without needing the app to be reopened.
  @override
  Future<void> scheduleOwnBirthdayCountdown(
    DateTime birthDate, {
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {
    await init();
    // Clear previous leads first so a changed DOB doesn't leave stale dates.
    for (final d in _ownBirthdayLeadDays) {
      await _plugin.cancel(NotificationIdFactory.ownBirthday(d));
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
        NotificationIdFactory.ownBirthday(lead.daysBefore),
        '🎂 Your birthday',
        body,
        _atTime(lead.date, reminderTime),
        _personalDetails(),
        payload: NotificationDestinationCodec.encode(
          const NotificationDestination.profile(),
        ),
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
  @override
  Future<void> scheduleNextDayMilestone(
    DateTime birthDate, {
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {
    await init();
    await _plugin.cancel(NotificationIdFactory.milestone);

    final now = tz.TZDateTime.now(tz.local);
    final milestone = AgeCalculationUtils.nextDayMilestone(
      birthDate,
      DateTime(now.year, now.month, now.day),
    );
    final scheduled = _atTime(milestone.date, reminderTime);
    if (!scheduled.isAfter(now)) {
      // Today's milestone time has already passed; the next one gets scheduled
      // the next time reminders are re-synced.
      return;
    }

    final formatted = AppDateUtils.formatLargeInteger(milestone.days);
    await _plugin.zonedSchedule(
      NotificationIdFactory.milestone,
      '🎂 $formatted days old!',
      'You\'re $formatted days old today. What a milestone!',
      scheduled,
      _personalDetails(),
      payload: NotificationDestinationCodec.encode(
        const NotificationDestination.milestone(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // One-shot: a given days-milestone happens exactly once.
    );
  }

  /// Cancels the user's own birthday-countdown and milestone reminders.
  @override
  Future<void> cancelOwnReminders() async {
    await init();
    for (final d in _ownBirthdayLeadDays) {
      await _plugin.cancel(NotificationIdFactory.ownBirthday(d));
    }
    await _plugin.cancel(NotificationIdFactory.milestone);
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

  tz.TZDateTime _atTime(DateTime date, BirthdayReminderTime time) {
    return tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  NotificationDetails _birthdayDetails() => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  ({String title, String body}) _birthdayCopy(
    SavedPerson person,
    int leadDays,
  ) {
    if (leadDays == 0) {
      return (
        title: '🎂 ${person.name}\'s birthday today!',
        body: 'Wish ${person.name} a happy birthday.',
      );
    }
    if (leadDays == 1) {
      return (
        title: '🎂 ${person.name}\'s birthday is tomorrow 🎉',
        body: '1 day until ${person.name}\'s birthday.',
      );
    }
    return (
      title: '🎂 ${person.name}\'s birthday is coming up',
      body: '$leadDays days until ${person.name}\'s birthday.',
    );
  }
}
