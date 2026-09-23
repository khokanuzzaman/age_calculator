import 'package:age_calculator/features/home/models/today_dashboard_state.dart';
import 'package:age_calculator/features/life_timeline/models/life_event.dart';
import 'package:age_calculator/features/profile/models/primary_profile.dart';
import 'package:age_calculator/features/saved_birthdays/models/saved_person.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty profile produces the setup dashboard state', () {
    final state = TodayDashboardState.fromSources(
      profile: null,
      now: DateTime(2026, 1, 1),
    );

    expect(state.hasProfile, isFalse);
    expect(state.age, isNull);
    expect(state.upcoming, isEmpty);
  });

  test(
    'personalized state derives age, birthday, milestone, and coming up',
    () {
      final state = TodayDashboardState.fromSources(
        profile: PrimaryProfile(birthDate: DateTime(1990, 1, 1)),
        now: DateTime(2026, 1, 1),
        savedBirthdays: [
          SavedPerson(
            id: 'friend',
            name: 'Friend',
            birthDate: DateTime(2000, 1, 5),
          ),
          SavedPerson(
            id: 'sibling',
            name: 'Sibling',
            birthDate: DateTime(2000, 1, 2),
          ),
        ],
        lifeEvents: [
          LifeEvent(id: 'soon', title: 'Soon', eventDate: DateTime(2026, 1, 3)),
          LifeEvent(
            id: 'past',
            title: 'Past',
            eventDate: DateTime(2025, 12, 31),
          ),
          LifeEvent(
            id: 'later',
            title: 'Later',
            eventDate: DateTime(2026, 1, 20),
          ),
        ],
      );

      expect(state.age?.years, 36);
      expect(state.birthdayIsToday, isTrue);
      expect(state.nextMilestone?.days, 14_000);
      expect(state.upcoming, hasLength(3));
      expect(state.upcoming.map((item) => item.title), [
        'Sibling',
        'Soon',
        'Friend',
      ]);
      expect(state.upcoming.any((item) => item.title == 'Past'), isFalse);
    },
  );

  test('birthday Coming Up item keeps only a local source reference', () {
    final state = TodayDashboardState.fromSources(
      profile: PrimaryProfile(birthDate: DateTime(1990, 1, 1)),
      savedBirthdays: [
        SavedPerson(
          id: 'person-1',
          name: 'Mom',
          birthDate: DateTime(1968, 10, 5),
        ),
      ],
      now: DateTime(2026, 9, 23),
    );

    final birthday = state.upcoming.single;
    expect(birthday.type, UpcomingItemType.birthday);
    expect(birthday.sourceId, 'person-1');
    expect(birthday.title, 'Mom');
  });
}
