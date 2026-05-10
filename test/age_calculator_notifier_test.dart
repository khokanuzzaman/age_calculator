import 'package:age_calculator/features/age_calculator/application/age_calculator_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
