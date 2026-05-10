/// "Life in Numbers" — playful, shareable estimates of what a person's body and
/// the world have done over their lifetime. All figures are deliberate
/// approximations based on common physiological averages; they are meant to be
/// fun and engaging, not medically precise.
class LifeFact {
  const LifeFact({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;

  /// Already-formatted display value (e.g. "2.1 billion").
  final String value;
}

class LifeFactsUtils {
  LifeFactsUtils._();

  // Common physiological / astronomical averages.
  static const double _heartBeatsPerMinute = 72;
  static const double _breathsPerMinute = 16;
  static const double _blinksPerDay = 20000; // waking blinks
  static const double _sleepFractionOfLife = 1 / 3; // ~8h per day
  static const double _lunarCycleDays = 29.53; // synodic month
  static const double _stepsPerDay = 5000; // moderate daily average

  static List<LifeFact> fromTotalDays(int totalDays) {
    final days = totalDays < 0 ? 0 : totalDays;
    final minutes = days * 24.0 * 60.0;

    final heartbeats = minutes * _heartBeatsPerMinute;
    final breaths = minutes * _breathsPerMinute;
    final blinks = days * _blinksPerDay;
    final sleepHours = days * 24.0 * _sleepFractionOfLife;
    final fullMoons = days / _lunarCycleDays;
    final steps = days * _stepsPerDay;
    final weekends = days / 7.0; // number of weeks ≈ number of weekends

    return [
      LifeFact(
        emoji: '❤️',
        label: 'Heartbeats',
        value: _compact(heartbeats),
      ),
      LifeFact(
        emoji: '🫁',
        label: 'Breaths taken',
        value: _compact(breaths),
      ),
      LifeFact(
        emoji: '😴',
        label: 'Hours slept',
        value: _compact(sleepHours),
      ),
      LifeFact(emoji: '👁️', label: 'Times blinked', value: _compact(blinks)),
      LifeFact(emoji: '👣', label: 'Steps walked', value: _compact(steps)),
      LifeFact(
        emoji: '🌕',
        label: 'Full moons seen',
        value: _compact(fullMoons),
      ),
      LifeFact(
        emoji: '🗓️',
        label: 'Weekends enjoyed',
        value: _compact(weekends),
      ),
    ];
  }

  /// Formats large numbers into a friendly compact form:
  /// 950 → "950", 12 300 → "12.3 thousand", 4 500 000 → "4.5 million",
  /// 2 100 000 000 → "2.1 billion".
  static String _compact(double n) {
    final value = n.isFinite ? n : 0;
    if (value >= 1e9) {
      return '${_trim(value / 1e9)} billion';
    }
    if (value >= 1e6) {
      return '${_trim(value / 1e6)} million';
    }
    if (value >= 1e3) {
      return '${_trim(value / 1e3)} thousand';
    }
    return value.round().toString();
  }

  static String _trim(double v) {
    // One decimal place, but drop a trailing ".0".
    final fixed = v.toStringAsFixed(1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }
}
