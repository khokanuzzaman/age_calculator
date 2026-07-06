/// Life Path number — a pure, offline calculation derived from a birth date.
///
/// This is presented as light entertainment, not a prediction. Everything here
/// is deterministic and locale-neutral.
class LifePathResult {
  const LifePathResult({required this.number, required this.meaning});

  /// The Life Path number: 1–9, or a master number 11 / 22 / 33.
  final int number;

  /// A short, neutral one-line description for [number].
  final String meaning;

  /// Master numbers are kept un-reduced by convention.
  bool get isMasterNumber => number == 11 || number == 22 || number == 33;
}

class NumerologyUtils {
  NumerologyUtils._();

  /// Computes the Life Path number using the standard component-reduction
  /// method, preserving master numbers 11, 22 and 33.
  ///
  /// The month, day and year are each reduced with [_reduceKeepingMaster]
  /// (masters preserved at every step — this is what lets 33 surface, which a
  /// full-reduce variant would miss), then summed and reduced once more.
  static LifePathResult lifePath(DateTime birthDate) {
    final month = _reduceKeepingMaster(birthDate.month);
    final day = _reduceKeepingMaster(birthDate.day);
    final year = _reduceKeepingMaster(birthDate.year);
    final number = _reduceKeepingMaster(month + day + year);
    return LifePathResult(number: number, meaning: _meanings[number] ?? '');
  }

  /// Repeatedly sums the digits of [value] until it is a single digit or one of
  /// the master numbers 11 / 22 / 33.
  static int _reduceKeepingMaster(int value) {
    var n = value;
    while (n > 9 && !_isMaster(n)) {
      n = _digitSum(n);
    }
    return n;
  }

  static bool _isMaster(int n) => n == 11 || n == 22 || n == 33;

  static int _digitSum(int n) {
    var sum = 0;
    var remaining = n;
    while (remaining > 0) {
      sum += remaining % 10;
      remaining ~/= 10;
    }
    return sum;
  }

  static const Map<int, String> _meanings = {
    1: 'The Leader — independent, driven and self-reliant.',
    2: 'The Peacemaker — cooperative, sensitive and diplomatic.',
    3: 'The Communicator — creative, expressive and sociable.',
    4: 'The Builder — practical, grounded and disciplined.',
    5: 'The Explorer — adventurous, curious and adaptable.',
    6: 'The Nurturer — caring, responsible and warm-hearted.',
    7: 'The Seeker — analytical, thoughtful and introspective.',
    8: 'The Achiever — ambitious, confident and goal-oriented.',
    9: 'The Humanitarian — compassionate, generous and idealistic.',
    11: 'The Visionary — a master number linked to intuition and insight.',
    22: 'The Master Builder — a master number linked to big ideas made real.',
    33: 'The Master Teacher — a rare master number linked to compassion.',
  };
}
