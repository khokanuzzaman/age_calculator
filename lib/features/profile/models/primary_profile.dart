import '../../../core/utils/date_utils.dart';

class PrimaryProfile {
  const PrimaryProfile({required this.birthDate, this.displayName});

  final DateTime birthDate;
  final String? displayName;

  PrimaryProfile copyWith({DateTime? birthDate, String? displayName}) {
    return PrimaryProfile(
      birthDate: birthDate ?? this.birthDate,
      displayName: displayName ?? this.displayName,
    );
  }

  PrimaryProfile normalized() {
    final name = displayName?.trim();
    return PrimaryProfile(
      birthDate: AppDateUtils.dateOnly(birthDate),
      displayName: name == null || name.isEmpty ? null : name,
    );
  }
}
