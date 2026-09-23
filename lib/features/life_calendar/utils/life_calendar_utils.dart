import '../../../core/utils/date_utils.dart';
import '../../age_calculator/domain/models/age_result.dart';
import '../../life_timeline/models/life_event.dart';
import '../models/life_calendar_model.dart';

class LifeCalendarUtils {
  LifeCalendarUtils._();

  static const List<int> horizonOptions = [80, 90, 100];

  static LifeCalendarSummary buildSummary({
    required DateTime birthDate,
    required int horizonYears,
    Iterable<LifeEvent> events = const [],
    DateTime? now,
  }) {
    final birth = AppDateUtils.dateOnly(birthDate);
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final safeHorizon = horizonOptions.contains(horizonYears)
        ? horizonYears
        : 90;
    final totalWeeks = safeHorizon * 52;
    final daysLived = today.isBefore(birth)
        ? 0
        : today.difference(birth).inDays;
    final completedWeeks = daysLived ~/ 7;
    final currentWeekIndex = completedWeeks.clamp(0, totalWeeks - 1);
    final age = today.isBefore(birth)
        ? const AgeSummary(years: 0, months: 0, days: 0)
        : _ageSummary(AppDateUtils.calculateAge(birth, today));
    final markers = _eventMarkers(
      birthDate: birth,
      horizonWeeks: totalWeeks,
      events: events,
    );

    final weeks = List<LifeCalendarWeek>.generate(totalWeeks, (index) {
      final startDate = birth.add(Duration(days: index * 7));
      return LifeCalendarWeek(
        index: index,
        startDate: startDate,
        isLived: index < completedWeeks || (index == 0 && daysLived >= 0),
        isCurrent: index == currentWeekIndex && !today.isBefore(birth),
        events: markers[index] ?? const [],
      );
    }, growable: false);

    return LifeCalendarSummary(
      birthDate: birth,
      today: today,
      horizonYears: safeHorizon,
      currentAge: age,
      currentWeekIndex: currentWeekIndex,
      completedWeeks: completedWeeks,
      weeks: weeks,
    );
  }

  static AgeSummary _ageSummary(AgeResult result) {
    return AgeSummary(
      years: result.years,
      months: result.months,
      days: result.days,
    );
  }

  static Map<int, List<LifeEventMarker>> _eventMarkers({
    required DateTime birthDate,
    required int horizonWeeks,
    required Iterable<LifeEvent> events,
  }) {
    // Life Calendar remains a historical map: recurring moments contribute
    // only their original marker, avoiding thousands of derived yearly cells.
    final result = <int, List<LifeEventMarker>>{};
    for (final event in events) {
      final eventDate = AppDateUtils.dateOnly(event.eventDate);
      if (eventDate.isBefore(birthDate)) {
        continue;
      }
      final weekIndex = eventDate.difference(birthDate).inDays ~/ 7;
      if (weekIndex < 0 || weekIndex >= horizonWeeks) {
        continue;
      }
      result
          .putIfAbsent(weekIndex, () => [])
          .add(LifeEventMarker(title: event.title, emoji: event.emoji));
    }
    return result;
  }
}
