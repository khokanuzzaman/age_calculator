import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../data/saved_birthdays_repository.dart';
import '../models/saved_person.dart';
import 'reminders_provider.dart';

final savedBirthdaysRepositoryProvider = Provider<SavedBirthdaysRepository>((
  ref,
) {
  return SavedBirthdaysRepository(ref.watch(sharedPreferencesProvider));
});

final savedBirthdaysProvider =
    NotifierProvider<SavedBirthdaysNotifier, List<SavedPerson>>(
      SavedBirthdaysNotifier.new,
    );

class SavedBirthdaysNotifier extends Notifier<List<SavedPerson>> {
  @override
  List<SavedPerson> build() {
    final people = ref.read(savedBirthdaysRepositoryProvider).load();
    return _sorted(people);
  }

  Future<void> addOrUpdate(SavedPerson person) async {
    final next = [...state];
    final index = next.indexWhere((p) => p.id == person.id);
    if (index >= 0) {
      next[index] = person;
    } else {
      next.add(person);
    }
    await _persist(_sorted(next));
  }

  Future<void> remove(String id) async {
    final next = state.where((p) => p.id != id).toList(growable: false);
    await _persist(next);
  }

  Future<void> _persist(List<SavedPerson> people) async {
    state = people;
    await ref.read(savedBirthdaysRepositoryProvider).save(people);
    try {
      await ref.read(remindersEnabledProvider.notifier).syncFromSavedList();
    } catch (_) {
      // Reminder sync is best-effort; never block a save on it.
    }
  }

  /// Sort by who has a birthday coming up soonest.
  List<SavedPerson> _sorted(List<SavedPerson> people) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final sorted = [...people];
    sorted.sort((a, b) {
      final da = AgeCalculationUtils.birthdayDetails(
        a.birthDate,
        today,
      ).daysUntilNextBirthday;
      final db = AgeCalculationUtils.birthdayDetails(
        b.birthDate,
        today,
      ).daysUntilNextBirthday;
      return da.compareTo(db);
    });
    return sorted;
  }
}
