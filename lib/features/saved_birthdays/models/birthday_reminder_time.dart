class BirthdayReminderTime {
  const BirthdayReminderTime({required this.hour, required this.minute});

  static const defaultTime = BirthdayReminderTime(hour: 9, minute: 0);

  final int hour;
  final int minute;

  BirthdayReminderTime normalized() {
    return BirthdayReminderTime(
      hour: hour.clamp(0, 23),
      minute: minute.clamp(0, 59),
    );
  }

  int get totalMinutes => (hour * 60) + minute;

  BirthdayReminderTime copyWith({int? hour, int? minute}) {
    return BirthdayReminderTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    ).normalized();
  }

  @override
  bool operator ==(Object other) {
    return other is BirthdayReminderTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}
