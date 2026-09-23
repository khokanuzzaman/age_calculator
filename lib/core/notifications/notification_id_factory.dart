/// Deterministic notification IDs shared by scheduling and cancellation.
///
/// Saved-person IDs use a positive namespace. The app's own reminders and
/// Life Timeline reminders use negative namespaces, so the categories cannot
/// collide even when their source IDs are similar.
class NotificationIdFactory {
  NotificationIdFactory._();

  static const savedBirthdayNamespace = 100000000;
  static const savedBirthdayRange = 700000000;
  static const ownBirthdayBase = -1000;
  static const milestone = -2000;
  static const lifeEventBase = -1000000000;

  static int savedBirthday(String personId, int leadDays) {
    final base = _stableHash('saved-person:$personId') % savedBirthdayRange;
    return savedBirthdayNamespace + base + leadDays;
  }

  static int ownBirthday(int leadDays) => ownBirthdayBase - leadDays;

  static int lifeEvent(String eventId) {
    return lifeEventBase - (_stableHash('life-event:$eventId') & 0x0fffffff);
  }

  static int lifeEventReminder(String eventId, int leadDays) {
    if (leadDays == 0) {
      return lifeEvent(eventId);
    }
    return lifeEventBase -
        (_stableHash('life-event:$eventId:lead:$leadDays') & 0x0fffffff);
  }

  static int stableHash(String value) {
    return _stableHash(value);
  }

  static int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
