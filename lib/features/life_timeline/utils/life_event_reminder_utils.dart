import '../../../core/utils/date_utils.dart';
import '../models/life_event.dart';
import '../models/life_event_recurrence.dart';
import 'life_event_utils.dart';

class LifeEventReminderSchedule {
  const LifeEventReminderSchedule({
    required this.occurrence,
    required this.leadDays,
    required this.scheduledDate,
  });

  final LifeEventOccurrence occurrence;
  final int leadDays;
  final DateTime scheduledDate;
}

class LifeEventReminderUtils {
  LifeEventReminderUtils._();

  static List<LifeEventReminderSchedule> upcomingSchedules(
    LifeEvent event, {
    DateTime? now,
  }) {
    if (!event.reminderEnabled) {
      return const [];
    }
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final occurrence = LifeEventUtils.nextOccurrence(event, now: today);
    if (occurrence == null) {
      return const [];
    }
    return [
      for (final leadDays in event.reminderPreferences.normalized(
        recurring: event.recurrence == LifeEventRecurrence.yearly,
      ))
        if (!occurrence.occurrenceDate
            .subtract(Duration(days: leadDays))
            .isBefore(today))
          LifeEventReminderSchedule(
            occurrence: occurrence,
            leadDays: leadDays,
            scheduledDate: occurrence.occurrenceDate.subtract(
              Duration(days: leadDays),
            ),
          ),
    ];
  }
}
