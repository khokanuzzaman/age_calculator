import 'package:shared_preferences/shared_preferences.dart';

import '../models/primary_profile.dart';

class PrimaryProfileRepository {
  PrimaryProfileRepository(this._prefs);

  static const birthDateKey = 'primary_birth_date_ms';
  static const displayNameKey = 'primary_profile_display_name';

  final SharedPreferences _prefs;

  PrimaryProfile? load() {
    final milliseconds = _prefs.getInt(birthDateKey);
    if (milliseconds == null) {
      return null;
    }

    final rawName = _prefs.getString(displayNameKey)?.trim();
    return PrimaryProfile(
      birthDate: DateTime.fromMillisecondsSinceEpoch(milliseconds),
      displayName: rawName == null || rawName.isEmpty ? null : rawName,
    ).normalized();
  }

  Future<void> save(PrimaryProfile profile) async {
    final normalized = profile.normalized();
    await _prefs.setInt(
      birthDateKey,
      normalized.birthDate.millisecondsSinceEpoch,
    );
    if (normalized.displayName == null) {
      await _prefs.remove(displayNameKey);
    } else {
      await _prefs.setString(displayNameKey, normalized.displayName!);
    }
  }

  Future<void> clear() async {
    await _prefs.remove(birthDateKey);
    await _prefs.remove(displayNameKey);
  }
}
