import '../../../core/utils/date_utils.dart';
import 'birthday_reminder_preferences.dart';

/// A birthday the user has saved to track (family, friend, pet, etc.).
class SavedPerson {
  const SavedPerson({
    required this.id,
    required this.name,
    required this.birthDate,
    this.emoji = '🎂',
    this.relation,
    this.isFavorite = false,
    this.reminderPreferences = const BirthdayReminderPreferences(),
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final String emoji;
  final String? relation;
  final bool isFavorite;
  final BirthdayReminderPreferences reminderPreferences;

  /// Current age in whole years as of [now].
  int ageInYears(DateTime now) {
    return AppDateUtils.calculateAge(
      AppDateUtils.dateOnly(birthDate),
      AppDateUtils.dateOnly(now),
    ).years;
  }

  SavedPerson copyWith({
    String? name,
    DateTime? birthDate,
    String? emoji,
    String? relation,
    bool? isFavorite,
    BirthdayReminderPreferences? reminderPreferences,
  }) {
    return SavedPerson(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      emoji: emoji ?? this.emoji,
      relation: relation ?? this.relation,
      isFavorite: isFavorite ?? this.isFavorite,
      reminderPreferences: reminderPreferences ?? this.reminderPreferences,
    );
  }

  factory SavedPerson.fromJson(Map<String, dynamic> json) {
    return SavedPerson(
      id: (json['id'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      birthDate: DateTime.fromMillisecondsSinceEpoch(
        (json['birthDateMs'] as num?)?.toInt() ?? 0,
      ),
      emoji: (json['emoji'] as String?)?.trim().isNotEmpty == true
          ? (json['emoji'] as String).trim()
          : '🎂',
      relation: (json['relation'] as String?)?.trim(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      reminderPreferences: BirthdayReminderPreferences.fromJson(
        (json['reminderPreferences'] as Map?)?.cast<String, dynamic>(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDateMs': birthDate.millisecondsSinceEpoch,
      'emoji': emoji,
      'relation': relation,
      'isFavorite': isFavorite,
      'reminderPreferences': reminderPreferences.toJson(),
    };
  }
}
