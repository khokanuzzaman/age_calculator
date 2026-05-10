import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_person.dart';

/// Persists the user's saved birthdays as a JSON list in SharedPreferences.
class SavedBirthdaysRepository {
  SavedBirthdaysRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'saved_birthdays_v1';

  List<SavedPerson> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((e) => SavedPerson.fromJson(e.cast<String, dynamic>()))
          .where((p) => p.id.isNotEmpty && p.name.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<SavedPerson> people) {
    final payload = people.map((e) => e.toJson()).toList(growable: false);
    return _prefs.setString(_key, jsonEncode(payload));
  }
}
