import '../../features/life_timeline/models/life_event.dart';
import '../../features/saved_birthdays/models/saved_person.dart';

/// The notification operations needed by reminder settings.
///
/// Keeping this boundary injectable lets reminder behavior be tested without
/// invoking platform notification channels.
abstract interface class NotificationGateway {
  Future<bool> requestPermission();

  Future<void> rescheduleAll(
    List<SavedPerson> people, {
    List<LifeEvent> events = const [],
  });

  Future<void> cancelAll();

  Future<void> scheduleOwnBirthdayCountdown(DateTime birthDate);

  Future<void> scheduleNextDayMilestone(DateTime birthDate);

  Future<void> cancelOwnReminders();
}
