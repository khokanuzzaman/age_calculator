import 'life_event_category.dart';
import 'life_event_recurrence.dart';
import 'life_event_reminder_preferences.dart';

/// A personal date the user wants to remember and understand in the context
/// of their age. Events are stored locally and never uploaded.
class LifeEvent {
  LifeEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    this.emoji = '⭐',
    bool? reminderEnabled,
    List<int>? reminderLeadDays,
    this.category = LifeEventCategory.personal,
    this.recurrence = LifeEventRecurrence.none,
    LifeEventReminderPreferences? reminderPreferences,
  }) : reminderPreferences =
           reminderPreferences ??
           LifeEventReminderPreferences(
             enabled: reminderEnabled ?? true,
             leadDays: reminderLeadDays ?? const [0],
           );

  final String id;
  final String title;
  final DateTime eventDate;
  final String emoji;
  final LifeEventCategory category;
  final LifeEventRecurrence recurrence;
  final LifeEventReminderPreferences reminderPreferences;

  bool get reminderEnabled => reminderPreferences.enabled;
  List<int> get reminderLeadDays => reminderPreferences.leadDays;

  LifeEvent copyWith({
    String? title,
    DateTime? eventDate,
    String? emoji,
    bool? reminderEnabled,
    List<int>? reminderLeadDays,
    LifeEventCategory? category,
    LifeEventRecurrence? recurrence,
    LifeEventReminderPreferences? reminderPreferences,
  }) {
    return LifeEvent(
      id: id,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      reminderPreferences:
          reminderPreferences ??
          this.reminderPreferences.copyWith(
            enabled: reminderEnabled,
            leadDays: reminderLeadDays,
          ),
    );
  }

  factory LifeEvent.fromJson(Map<String, dynamic> json) {
    final category = LifeEventCategory.values.firstWhere(
      (value) => value.name == json['category'],
      orElse: () => LifeEventCategory.personal,
    );
    final recurrence = LifeEventRecurrence.values.firstWhere(
      (value) => value.name == json['recurrence'],
      orElse: () => LifeEventRecurrence.none,
    );
    final nestedPreferences = LifeEventReminderPreferences.fromJson(
      (json['reminderPreferences'] as Map?)?.cast<String, dynamic>(),
    );
    final rawLeadDays = json['reminderLeadDays'];
    final legacyLeadDays = rawLeadDays is List
        ? rawLeadDays.whereType<num>().map((value) => value.toInt()).toList()
        : null;
    return LifeEvent(
      id: (json['id'] as String?)?.trim() ?? '',
      title: (json['title'] as String?)?.trim() ?? '',
      eventDate: DateTime.fromMillisecondsSinceEpoch(
        (json['eventDateMs'] as num?)?.toInt() ?? 0,
      ),
      emoji: (json['emoji'] as String?)?.trim().isNotEmpty == true
          ? (json['emoji'] as String).trim()
          : '⭐',
      category: category,
      recurrence: recurrence,
      reminderPreferences: json['reminderPreferences'] is Map
          ? nestedPreferences
          : LifeEventReminderPreferences(
              enabled: json['reminderEnabled'] as bool? ?? true,
              leadDays:
                  legacyLeadDays ??
                  (recurrence == LifeEventRecurrence.yearly
                      ? const [1, 0]
                      : const [0]),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'eventDateMs': eventDate.millisecondsSinceEpoch,
      'emoji': emoji,
      'reminderEnabled': reminderEnabled,
      'reminderLeadDays': reminderLeadDays,
      'reminderPreferences': reminderPreferences.toJson(),
      'category': category.name,
      'recurrence': recurrence.name,
    };
  }
}
