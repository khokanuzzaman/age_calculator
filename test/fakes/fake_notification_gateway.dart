import 'package:age_calculator/core/notifications/notification_gateway.dart';
import 'package:age_calculator/features/life_timeline/models/life_event.dart';
import 'package:age_calculator/features/saved_birthdays/models/saved_person.dart';

class FakeNotificationGateway implements NotificationGateway {
  bool permissionGranted = true;
  int cancelAllCalls = 0;
  int rescheduleAllCalls = 0;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> rescheduleAll(
    List<SavedPerson> people, {
    List<LifeEvent> events = const [],
  }) async {
    rescheduleAllCalls++;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
  }

  @override
  Future<void> scheduleOwnBirthdayCountdown(DateTime birthDate) async {}

  @override
  Future<void> scheduleNextDayMilestone(DateTime birthDate) async {}

  @override
  Future<void> cancelOwnReminders() async {}
}
