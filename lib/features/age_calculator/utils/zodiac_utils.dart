/// Globally-relevant astrological and calendar facts derived from a birth date.
///
/// Everything here is pure, offline, and locale-neutral so it works for any user
/// regardless of region. Western zodiac, Chinese zodiac, birthstone, and birth
/// flower are all computed from the Gregorian birth date.
class ZodiacInfo {
  const ZodiacInfo({
    required this.westernSign,
    required this.westernSymbol,
    required this.westernElement,
    required this.westernDateRange,
    required this.westernTraits,
    required this.chineseAnimal,
    required this.chineseEmoji,
    required this.chineseElement,
    required this.birthstone,
    required this.birthFlower,
  });

  final String westernSign;
  final String westernSymbol;
  final String westernElement;
  final String westernDateRange;
  final String westernTraits;
  final String chineseAnimal;
  final String chineseEmoji;
  final String chineseElement;
  final String birthstone;
  final String birthFlower;
}

class ZodiacUtils {
  ZodiacUtils._();

  static ZodiacInfo fromBirthDate(DateTime birthDate) {
    final western = _westernSign(birthDate.month, birthDate.day);
    final chineseAnimal = _chineseAnimal(birthDate.year);
    return ZodiacInfo(
      westernSign: western.name,
      westernSymbol: western.symbol,
      westernElement: western.element,
      westernDateRange: western.range,
      westernTraits: western.traits,
      chineseAnimal: chineseAnimal.name,
      chineseEmoji: chineseAnimal.emoji,
      chineseElement: _chineseElement(birthDate.year),
      birthstone: _birthstone(birthDate.month),
      birthFlower: _birthFlower(birthDate.month),
    );
  }

  static _WesternSign _westernSign(int month, int day) {
    // Each entry: sign is valid up to and including (cutoffMonth, cutoffDay).
    for (final sign in _westernSigns) {
      if (month < sign.cutoffMonth ||
          (month == sign.cutoffMonth && day <= sign.cutoffDay)) {
        return sign;
      }
    }
    // After Dec 21 → Capricorn (wraps into January).
    return _westernSigns.first;
  }

  static _ChineseAnimal _chineseAnimal(int year) {
    // Approximate: keyed to the Gregorian year. The exact Chinese New Year
    // boundary (late Jan / mid Feb) is intentionally ignored for simplicity,
    // matching how most consumer apps present this.
    final index = ((year - 4) % 12 + 12) % 12;
    return _chineseAnimals[index];
  }

  static String _chineseElement(int year) {
    final stem = ((year % 10) + 10) % 10;
    return switch (stem) {
      4 || 5 => 'Wood',
      6 || 7 => 'Fire',
      8 || 9 => 'Earth',
      0 || 1 => 'Metal',
      _ => 'Water',
    };
  }

  static String _birthstone(int month) => _birthstones[month - 1];

  static String _birthFlower(int month) => _birthFlowers[month - 1];

  // Capricorn first so the wrap-around (after Dec 21) resolves to it.
  static const List<_WesternSign> _westernSigns = [
    _WesternSign(
      'Capricorn',
      '♑',
      'Earth',
      'Dec 22 – Jan 19',
      'Disciplined, responsible, ambitious',
      1,
      19,
    ),
    _WesternSign(
      'Aquarius',
      '♒',
      'Air',
      'Jan 20 – Feb 18',
      'Independent, original, humanitarian',
      2,
      18,
    ),
    _WesternSign(
      'Pisces',
      '♓',
      'Water',
      'Feb 19 – Mar 20',
      'Compassionate, artistic, intuitive',
      3,
      20,
    ),
    _WesternSign(
      'Aries',
      '♈',
      'Fire',
      'Mar 21 – Apr 19',
      'Bold, energetic, confident',
      4,
      19,
    ),
    _WesternSign(
      'Taurus',
      '♉',
      'Earth',
      'Apr 20 – May 20',
      'Reliable, patient, devoted',
      5,
      20,
    ),
    _WesternSign(
      'Gemini',
      '♊',
      'Air',
      'May 21 – Jun 20',
      'Curious, adaptable, expressive',
      6,
      20,
    ),
    _WesternSign(
      'Cancer',
      '♋',
      'Water',
      'Jun 21 – Jul 22',
      'Loyal, emotional, caring',
      7,
      22,
    ),
    _WesternSign(
      'Leo',
      '♌',
      'Fire',
      'Jul 23 – Aug 22',
      'Warm, generous, charismatic',
      8,
      22,
    ),
    _WesternSign(
      'Virgo',
      '♍',
      'Earth',
      'Aug 23 – Sep 22',
      'Analytical, practical, kind',
      9,
      22,
    ),
    _WesternSign(
      'Libra',
      '♎',
      'Air',
      'Sep 23 – Oct 22',
      'Diplomatic, fair, social',
      10,
      22,
    ),
    _WesternSign(
      'Scorpio',
      '♏',
      'Water',
      'Oct 23 – Nov 21',
      'Passionate, resourceful, brave',
      11,
      21,
    ),
    _WesternSign(
      'Sagittarius',
      '♐',
      'Fire',
      'Nov 22 – Dec 21',
      'Optimistic, adventurous, honest',
      12,
      21,
    ),
  ];

  static const List<_ChineseAnimal> _chineseAnimals = [
    _ChineseAnimal('Rat', '🐀'),
    _ChineseAnimal('Ox', '🐂'),
    _ChineseAnimal('Tiger', '🐅'),
    _ChineseAnimal('Rabbit', '🐇'),
    _ChineseAnimal('Dragon', '🐉'),
    _ChineseAnimal('Snake', '🐍'),
    _ChineseAnimal('Horse', '🐎'),
    _ChineseAnimal('Goat', '🐐'),
    _ChineseAnimal('Monkey', '🐒'),
    _ChineseAnimal('Rooster', '🐓'),
    _ChineseAnimal('Dog', '🐕'),
    _ChineseAnimal('Pig', '🐖'),
  ];

  static const List<String> _birthstones = [
    'Garnet',
    'Amethyst',
    'Aquamarine',
    'Diamond',
    'Emerald',
    'Pearl',
    'Ruby',
    'Peridot',
    'Sapphire',
    'Opal',
    'Topaz',
    'Turquoise',
  ];

  static const List<String> _birthFlowers = [
    'Carnation',
    'Violet',
    'Daffodil',
    'Daisy',
    'Lily of the Valley',
    'Rose',
    'Larkspur',
    'Gladiolus',
    'Aster',
    'Marigold',
    'Chrysanthemum',
    'Narcissus',
  ];
}

class _WesternSign {
  const _WesternSign(
    this.name,
    this.symbol,
    this.element,
    this.range,
    this.traits,
    this.cutoffMonth,
    this.cutoffDay,
  );

  final String name;
  final String symbol;
  final String element;
  final String range;
  final String traits;
  final int cutoffMonth;
  final int cutoffDay;
}

class _ChineseAnimal {
  const _ChineseAnimal(this.name, this.emoji);

  final String name;
  final String emoji;
}
