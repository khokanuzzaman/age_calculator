import 'package:age_calculator/features/saved_birthdays/data/saved_birthdays_repository.dart';
import 'package:age_calculator/features/saved_birthdays/models/saved_person.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('round-trips saved people through storage', () async {
    final repo = SavedBirthdaysRepository(prefs);
    final people = [
      SavedPerson(id: '1', name: 'Mom', birthDate: DateTime(1970, 5, 4)),
      SavedPerson(
        id: '2',
        name: 'Buddy',
        birthDate: DateTime(2018, 11, 20),
        emoji: '🐶',
      ),
    ];

    await repo.save(people);
    final loaded = repo.load();

    expect(loaded, hasLength(2));
    expect(loaded.first.name, 'Mom');
    expect(loaded.first.birthDate, DateTime(1970, 5, 4));
    expect(loaded[1].emoji, '🐶');
  });

  test('returns empty list when nothing is stored', () {
    expect(SavedBirthdaysRepository(prefs).load(), isEmpty);
  });

  test('ageInYears computes whole years', () {
    final person = SavedPerson(
      id: '1',
      name: 'Test',
      birthDate: DateTime(2000, 1, 1),
    );
    expect(person.ageInYears(DateTime(2020, 6, 1)), 20);
  });
}
