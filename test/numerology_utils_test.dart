import 'package:age_calculator/features/age_calculator/utils/numerology_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumerologyUtils.lifePath', () {
    // Hand-verified using the component-reduction, master-preserving method:
    // reduce(month) + reduce(day) + reduce(year), then reduce the total.
    test('reduces to a single digit (normal case)', () {
      // 1 + reduce(15)=6 + reduce(1990)=1 => 8
      final result = NumerologyUtils.lifePath(DateTime(1990, 1, 15));
      expect(result.number, 8);
      expect(result.isMasterNumber, isFalse);
      expect(result.meaning, isNotEmpty);
    });

    test('preserves master number 11', () {
      // 2 + 3 + reduce(1950)=6 => 11 (master, not reduced)
      final result = NumerologyUtils.lifePath(DateTime(1950, 2, 3));
      expect(result.number, 11);
      expect(result.isMasterNumber, isTrue);
      expect(result.meaning, isNotEmpty);
    });

    test('preserves master number 22', () {
      // 4 + 9 + reduce(1980)=9 => 22 (master)
      final result = NumerologyUtils.lifePath(DateTime(1980, 4, 9));
      expect(result.number, 22);
      expect(result.isMasterNumber, isTrue);
    });

    test('preserves master number 33', () {
      // reduce(11)=11 + reduce(29)=11 + reduce(1910)=11 => 33 (master)
      final result = NumerologyUtils.lifePath(DateTime(1910, 11, 29));
      expect(result.number, 33);
      expect(result.isMasterNumber, isTrue);
    });

    test('handles multiple reduction passes', () {
      // reduce(12)=3 + reduce(28)=(28->10->1) + reduce(1999)=(1999->28->10->1)
      // => 3 + 1 + 1 = 5
      final result = NumerologyUtils.lifePath(DateTime(1999, 12, 28));
      expect(result.number, 5);
      expect(result.isMasterNumber, isFalse);
    });

    test('every produced number has a meaning', () {
      final dates = [
        DateTime(1990, 1, 15),
        DateTime(1950, 2, 3),
        DateTime(1980, 4, 9),
        DateTime(1910, 11, 29),
        DateTime(1999, 12, 28),
      ];
      for (final date in dates) {
        expect(NumerologyUtils.lifePath(date).meaning, isNotEmpty);
      }
    });
  });
}
