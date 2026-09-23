import 'package:age_calculator/features/life_calendar/utils/life_calendar_utils.dart';
import 'package:age_calculator/features/life_timeline/models/life_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a 90-year calendar with the current week highlighted', () {
    final summary = LifeCalendarUtils.buildSummary(
      birthDate: DateTime(2000, 1, 1),
      horizonYears: 90,
      now: DateTime(2000, 1, 15),
    );

    expect(summary.totalWeeks, 4680);
    expect(summary.completedWeeks, 2);
    expect(summary.currentWeekIndex, 2);
    expect(summary.weeks[0].isLived, isTrue);
    expect(summary.weeks[1].isLived, isTrue);
    expect(summary.weeks[2].isCurrent, isTrue);
  });

  test('marks timeline events in their corresponding week', () {
    final summary = LifeCalendarUtils.buildSummary(
      birthDate: DateTime(2000, 1, 1),
      horizonYears: 80,
      now: DateTime(2026, 1, 1),
      events: [
        LifeEvent(
          id: 'graduation',
          title: 'Graduation',
          eventDate: DateTime(2000, 1, 8),
          emoji: '🎓',
        ),
        LifeEvent(
          id: 'before-birth',
          title: 'Before birth',
          eventDate: DateTime(1999, 12, 31),
        ),
      ],
    );

    expect(summary.totalWeeks, 4160);
    expect(summary.eventCount, 1);
    expect(summary.weeks[1].events.single.title, 'Graduation');
    expect(summary.weeks[1].events.single.emoji, '🎓');
  });

  test('falls back to a 90-year visual horizon for invalid values', () {
    final summary = LifeCalendarUtils.buildSummary(
      birthDate: DateTime(1990, 1, 1),
      horizonYears: 75,
      now: DateTime(2026, 1, 1),
    );

    expect(summary.horizonYears, 90);
    expect(summary.totalWeeks, 4680);
  });
}
