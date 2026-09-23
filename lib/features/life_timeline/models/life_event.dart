/// A personal date the user wants to remember and understand in the context
/// of their age. Events are stored locally and never uploaded.
class LifeEvent {
  const LifeEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    this.emoji = '⭐',
    this.reminderEnabled = true,
  });

  final String id;
  final String title;
  final DateTime eventDate;
  final String emoji;
  final bool reminderEnabled;

  LifeEvent copyWith({
    String? title,
    DateTime? eventDate,
    String? emoji,
    bool? reminderEnabled,
  }) {
    return LifeEvent(
      id: id,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      emoji: emoji ?? this.emoji,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  factory LifeEvent.fromJson(Map<String, dynamic> json) {
    return LifeEvent(
      id: (json['id'] as String?)?.trim() ?? '',
      title: (json['title'] as String?)?.trim() ?? '',
      eventDate: DateTime.fromMillisecondsSinceEpoch(
        (json['eventDateMs'] as num?)?.toInt() ?? 0,
      ),
      emoji: (json['emoji'] as String?)?.trim().isNotEmpty == true
          ? (json['emoji'] as String).trim()
          : '⭐',
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'eventDateMs': eventDate.millisecondsSinceEpoch,
      'emoji': emoji,
      'reminderEnabled': reminderEnabled,
    };
  }
}
