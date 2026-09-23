import 'package:age_calculator/core/utils/date_utils.dart';

import '../../age_calculator/domain/models/age_result.dart';
import '../../age_calculator/models/age_milestone_model.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../../life_timeline/models/life_event.dart';
import '../../profile/models/primary_profile.dart';
import '../../saved_birthdays/models/saved_person.dart';

enum UpcomingItemType { birthday, lifeEvent }

class UpcomingItem {
  const UpcomingItem({
    required this.type,
    required this.title,
    required this.emoji,
    required this.targetDate,
    required this.daysRemaining,
    this.sourceId,
  });

  final UpcomingItemType type;
  final String title;
  final String emoji;
  final DateTime targetDate;
  final int daysRemaining;
  final String? sourceId;
}

class TodayDashboardState {
  const TodayDashboardState({
    required this.profile,
    required this.now,
    this.age,
    this.birthday,
    this.nextMilestone,
    this.upcoming = const [],
  });

  final PrimaryProfile? profile;
  final DateTime now;
  final AgeResult? age;
  final BirthdayDetails? birthday;
  final DayMilestone? nextMilestone;
  final List<UpcomingItem> upcoming;

  bool get hasProfile => profile != null;
  bool get birthdayIsToday => birthday?.daysUntilNextBirthday == 0;

  factory TodayDashboardState.fromSources({
    required PrimaryProfile? profile,
    Iterable<SavedPerson> savedBirthdays = const [],
    Iterable<LifeEvent> lifeEvents = const [],
    DateTime? now,
  }) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    if (profile == null) {
      return TodayDashboardState(profile: null, now: today);
    }

    final age = AppDateUtils.calculateAge(profile.birthDate, today);
    final birthday = AgeCalculationUtils.birthdayDetails(
      profile.birthDate,
      today,
    );
    final nextMilestone = AgeCalculationUtils.nextDayMilestone(
      profile.birthDate,
      today,
    );
    final items = <UpcomingItem>[];

    for (final person in savedBirthdays) {
      final details = AgeCalculationUtils.birthdayDetails(
        person.birthDate,
        today,
      );
      items.add(
        UpcomingItem(
          type: UpcomingItemType.birthday,
          title: person.name,
          emoji: person.emoji,
          targetDate: details.nextBirthdayDate,
          daysRemaining: details.daysUntilNextBirthday,
          sourceId: person.id,
        ),
      );
    }

    for (final event in lifeEvents) {
      final targetDate = AppDateUtils.dateOnly(event.eventDate);
      if (targetDate.isBefore(today)) {
        continue;
      }
      items.add(
        UpcomingItem(
          type: UpcomingItemType.lifeEvent,
          title: event.title,
          emoji: event.emoji,
          targetDate: targetDate,
          daysRemaining: targetDate.difference(today).inDays,
        ),
      );
    }

    items.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    return TodayDashboardState(
      profile: profile,
      now: today,
      age: age,
      birthday: birthday,
      nextMilestone: nextMilestone,
      upcoming: List.unmodifiable(items.take(3)),
    );
  }
}
