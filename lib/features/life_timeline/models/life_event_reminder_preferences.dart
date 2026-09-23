/// Reminder settings stored with a LifeEvent.
class LifeEventReminderPreferences {
  const LifeEventReminderPreferences({
    this.enabled = true,
    this.leadDays = const [0],
  });

  final bool enabled;
  final List<int> leadDays;

  List<int> normalized({required bool recurring}) {
    final allowed = leadDays.where(const {0, 1, 7}.contains).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (!recurring) {
      return const [0];
    }
    return allowed.isEmpty ? const [1, 0] : List.unmodifiable(allowed);
  }

  LifeEventReminderPreferences copyWith({bool? enabled, List<int>? leadDays}) {
    return LifeEventReminderPreferences(
      enabled: enabled ?? this.enabled,
      leadDays: leadDays ?? this.leadDays,
    );
  }

  factory LifeEventReminderPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LifeEventReminderPreferences();
    }
    final rawLeads = json['leadDays'];
    return LifeEventReminderPreferences(
      enabled: json['enabled'] as bool? ?? true,
      leadDays: rawLeads is List
          ? rawLeads.whereType<num>().map((value) => value.toInt()).toList()
          : const [0],
    );
  }

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'leadDays': leadDays};
  }

  @override
  bool operator ==(Object other) {
    return other is LifeEventReminderPreferences &&
        other.enabled == enabled &&
        _sameList(other.leadDays, leadDays);
  }

  @override
  int get hashCode => Object.hash(enabled, Object.hashAll(leadDays));

  static bool _sameList(List<int> first, List<int> second) {
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
