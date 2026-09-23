import '../../../core/utils/date_utils.dart';

enum CountdownDirection { future, past, today }

extension CountdownDirectionLabel on CountdownDirection {
  String get analyticsValue => switch (this) {
    CountdownDirection.future => 'future',
    CountdownDirection.past => 'past',
    CountdownDirection.today => 'today',
  };
}

class CountdownResult {
  const CountdownResult({
    required this.targetDate,
    required this.today,
    required this.direction,
    required this.totalDays,
    required this.weeks,
    required this.remainingDays,
    required this.weekday,
  });

  final DateTime targetDate;
  final DateTime today;
  final CountdownDirection direction;
  final int totalDays;
  final int weeks;
  final int remainingDays;
  final String weekday;
}

class CountdownUtils {
  CountdownUtils._();

  static CountdownResult calculate({
    required DateTime targetDate,
    required DateTime today,
  }) {
    final target = AppDateUtils.dateOnly(targetDate);
    final reference = AppDateUtils.dateOnly(today);
    final difference = target.difference(reference).inDays;
    final direction = difference == 0
        ? CountdownDirection.today
        : difference.isNegative
        ? CountdownDirection.past
        : CountdownDirection.future;
    final totalDays = difference.abs();
    return CountdownResult(
      targetDate: target,
      today: reference,
      direction: direction,
      totalDays: totalDays,
      weeks: totalDays ~/ 7,
      remainingDays: totalDays % 7,
      weekday: AppDateUtils.weekdayName(target),
    );
  }
}
