import 'package:age_calculator/core/notifications/notification_gateway.dart';
import 'package:age_calculator/features/life_timeline/models/life_event.dart';
import 'package:age_calculator/features/saved_birthdays/models/birthday_reminder_time.dart';
import 'package:age_calculator/features/saved_birthdays/models/saved_person.dart';

class FakeNotificationGateway implements NotificationGateway {
  bool permissionGranted = true;
  int cancelAllCalls = 0;
  int rescheduleAllCalls = 0;
  int syncPersonCalls = 0;
  int cancelPersonCalls = 0;
  final syncedPeople = <SavedPerson>[];
  final cancelledPersonIds = <String>[];

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> rescheduleAll(
    List<SavedPerson> people, {
    List<LifeEvent> events = const [],
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {
    rescheduleAllCalls++;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
  }

  @override
  Future<void> scheduleOwnBirthdayCountdown(
    DateTime birthDate, {
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {}

  @override
  Future<void> scheduleNextDayMilestone(
    DateTime birthDate, {
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {}

  @override
  Future<void> cancelOwnReminders() async {}

  @override
  Future<void> syncPerson(
    SavedPerson person, {
    BirthdayReminderTime reminderTime = BirthdayReminderTime.defaultTime,
  }) async {
    syncPersonCalls++;
    syncedPeople.add(person);
  }

  @override
  Future<void> cancelPersonReminders(String personId) async {
    cancelPersonCalls++;
    cancelledPersonIds.add(personId);
  }
}
