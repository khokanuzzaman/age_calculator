import '../../../core/utils/date_utils.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../models/saved_person.dart';

enum SavedPeopleFilter { upcoming, thisMonth, favorites, all }

class SavedPeopleUtils {
  SavedPeopleUtils._();

  static List<SavedPerson> filter(
    Iterable<SavedPerson> people, {
    required SavedPeopleFilter filter,
    String query = '',
    DateTime? now,
  }) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = people
        .where((person) {
          final matchesQuery =
              normalizedQuery.isEmpty ||
              person.name.toLowerCase().contains(normalizedQuery) ||
              (person.relation?.toLowerCase().contains(normalizedQuery) ??
                  false);
          if (!matchesQuery) {
            return false;
          }
          return switch (filter) {
            SavedPeopleFilter.upcoming || SavedPeopleFilter.all => true,
            SavedPeopleFilter.thisMonth =>
              AgeCalculationUtils.birthdayDetails(
                    person.birthDate,
                    today,
                  ).nextBirthdayDate.month ==
                  today.month,
            SavedPeopleFilter.favorites => person.isFavorite,
          };
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final aDate = AgeCalculationUtils.birthdayDetails(
        a.birthDate,
        today,
      ).nextBirthdayDate;
      final bDate = AgeCalculationUtils.birthdayDetails(
        b.birthDate,
        today,
      ).nextBirthdayDate;
      return aDate.compareTo(bDate);
    });
    return filtered;
  }
}
