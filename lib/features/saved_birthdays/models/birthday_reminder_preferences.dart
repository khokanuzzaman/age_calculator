/// Per-person birthday reminder settings stored with a [SavedPerson].
class BirthdayReminderPreferences {
  const BirthdayReminderPreferences({
    this.enabled = true,
    this.leadDays = const [0],
  });

  static const supportedLeadDays = [30, 7, 3, 1, 0];

  final bool enabled;
  final List<int> leadDays;

  BirthdayReminderPreferences normalized() {
    final normalizedDays =
        leadDays.where(supportedLeadDays.contains).toSet().toList()..sort(
          (a, b) => supportedLeadDays
              .indexOf(a)
              .compareTo(supportedLeadDays.indexOf(b)),
        );
    if (enabled && normalizedDays.isEmpty) {
      normalizedDays.add(0);
    }
    return BirthdayReminderPreferences(
      enabled: enabled,
      leadDays: List.unmodifiable(normalizedDays),
    );
  }

  factory BirthdayReminderPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const BirthdayReminderPreferences();
    }
    return BirthdayReminderPreferences(
      enabled: json['enabled'] as bool? ?? true,
      leadDays:
          (json['leadDays'] as List<dynamic>?)
              ?.whereType<num>()
              .map((value) => value.toInt())
              .toList(growable: false) ??
          const [0],
    ).normalized();
  }

  Map<String, dynamic> toJson() {
    final normalizedPreferences = normalized();
    return {
      'enabled': normalizedPreferences.enabled,
      'leadDays': normalizedPreferences.leadDays,
    };
  }

  BirthdayReminderPreferences copyWith({bool? enabled, List<int>? leadDays}) {
    return BirthdayReminderPreferences(
      enabled: enabled ?? this.enabled,
      leadDays: leadDays ?? this.leadDays,
    ).normalized();
  }

  @override
  bool operator ==(Object other) {
    return other is BirthdayReminderPreferences &&
        other.enabled == enabled &&
        _sameDays(other.leadDays, leadDays);
  }

  @override
  int get hashCode => Object.hash(enabled, Object.hashAll(leadDays));

  static bool _sameDays(List<int> first, List<int> second) {
    if (first.length != second.length) {
      return false;
    }
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }
}
