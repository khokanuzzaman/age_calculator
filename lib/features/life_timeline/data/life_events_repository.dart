import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/life_event.dart';

/// Persists private life events locally as a JSON list.
class LifeEventsRepository {
  LifeEventsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'life_events_v1';

  List<LifeEvent> load() {
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
          .map((item) => LifeEvent.fromJson(item.cast<String, dynamic>()))
          .where((event) => event.id.isNotEmpty && event.title.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<LifeEvent> events) {
    final payload = events
        .map((event) => event.toJson())
        .toList(growable: false);
    return _prefs.setString(_key, jsonEncode(payload));
  }
}
