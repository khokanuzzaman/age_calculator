import 'package:age_calculator/app/theme/theme_mode_notifier.dart';
import 'package:age_calculator/features/age_calculator/application/age_calculator_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('AgeCalculatorNotifier', () {
    test('starts with no birth date and no result', () {
      final container = createContainer();
      final state = container.read(ageCalculatorProvider);

      expect(state.birthDate, isNull);
      expect(state.result, isNull);
      expect(state.errorMessage, isNull);
    });

    test('calculates result from selected dates', () {
      final container = createContainer();
      final notifier = container.read(ageCalculatorProvider.notifier);

      notifier.setBirthDate(DateTime(1995, 6, 15));
      notifier.setAsOfDate(DateTime(2026, 4, 20));
      notifier.calculate();

      final state = container.read(ageCalculatorProvider);
      expect(state.errorMessage, isNull);
      expect(state.result, isNotNull);
      expect(state.result!.years, 30);
      expect(state.result!.months, 10);
      expect(state.result!.days, 5);
      expect(state.result!.dayOfWeekBorn, 'Thursday');
    });

    test('sets validation message when birth date is missing', () {
      final container = createContainer();
      final notifier = container.read(ageCalculatorProvider.notifier);

      notifier.calculate();

      final state = container.read(ageCalculatorProvider);
      expect(state.result, isNull);
      expect(state.errorMessage, 'Select your date of birth first.');
    });

    test('reset clears selected birth date and result', () {
      final container = createContainer();
      final notifier = container.read(ageCalculatorProvider.notifier);

      notifier.setBirthDate(DateTime(1995, 6, 15));
      notifier.calculate();
      notifier.reset();

      final state = container.read(ageCalculatorProvider);
      expect(state.birthDate, isNull);
      expect(state.result, isNull);
      expect(state.errorMessage, isNull);
    });
  });

  group('AgeCalculatorNotifier last birth date', () {
    Future<ProviderContainer> containerWith(SharedPreferences prefs) async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test(
      'remembers the last calculated birth date across containers',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final first = await containerWith(prefs);

        final notifier = first.read(ageCalculatorProvider.notifier);
        notifier.setBirthDate(DateTime(1995, 6, 15));
        notifier.calculate();

        final second = await containerWith(prefs);
        final state = second.read(ageCalculatorProvider);
        expect(state.birthDate, DateTime(1995, 6, 15));
        expect(state.result, isNull);
      },
    );

    test('does not store a birth date that was never calculated', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final first = await containerWith(prefs);

      first
          .read(ageCalculatorProvider.notifier)
          .setBirthDate(DateTime(1995, 6, 15));

      final second = await containerWith(prefs);
      expect(second.read(ageCalculatorProvider).birthDate, isNull);
    });

    test('ignores an invalid stored value', () async {
      SharedPreferences.setMockInitialValues({'last_birth_date': 'garbage'});
      final prefs = await SharedPreferences.getInstance();
      final container = await containerWith(prefs);

      expect(container.read(ageCalculatorProvider).birthDate, isNull);
    });

    test('ignores a stored year before 1900', () async {
      SharedPreferences.setMockInitialValues({
        'last_birth_date': DateTime(1899, 12, 31).toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final container = await containerWith(prefs);

      expect(container.read(ageCalculatorProvider).birthDate, isNull);
    });

    test('ignores a stored future date', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 2));
      SharedPreferences.setMockInitialValues({
        'last_birth_date': tomorrow.toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final container = await containerWith(prefs);

      expect(container.read(ageCalculatorProvider).birthDate, isNull);
    });

    test('reset still clears the restored birth date', () async {
      SharedPreferences.setMockInitialValues({
        'last_birth_date': DateTime(1990, 1, 2).toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final container = await containerWith(prefs);
      expect(
        container.read(ageCalculatorProvider).birthDate,
        DateTime(1990, 1, 2),
      );

      container.read(ageCalculatorProvider.notifier).reset();

      expect(container.read(ageCalculatorProvider).birthDate, isNull);
    });
  });
}
