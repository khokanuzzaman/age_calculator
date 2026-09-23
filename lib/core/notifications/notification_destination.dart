enum NotificationDestinationType {
  person,
  lifeEvent,
  profile,
  lifeTimeline,
  milestone,
}

class NotificationDestination {
  const NotificationDestination._(this.type, [this.localId]);

  const NotificationDestination.person(String id)
    : this._(NotificationDestinationType.person, id);
  const NotificationDestination.lifeEvent(String id)
    : this._(NotificationDestinationType.lifeEvent, id);
  const NotificationDestination.profile()
    : this._(NotificationDestinationType.profile);
  const NotificationDestination.lifeTimeline()
    : this._(NotificationDestinationType.lifeTimeline);
  const NotificationDestination.milestone()
    : this._(NotificationDestinationType.milestone);

  final NotificationDestinationType type;
  final String? localId;

  String get analyticsDestination => switch (type) {
    NotificationDestinationType.person => 'person',
    NotificationDestinationType.lifeEvent => 'life_event',
    NotificationDestinationType.profile => 'profile',
    NotificationDestinationType.lifeTimeline => 'timeline',
    NotificationDestinationType.milestone => 'milestone',
  };

  String get reminderType => switch (type) {
    NotificationDestinationType.person => 'birthday',
    NotificationDestinationType.lifeEvent => 'life_event',
    NotificationDestinationType.profile => 'birthday',
    NotificationDestinationType.lifeTimeline => 'life_event',
    NotificationDestinationType.milestone => 'personal',
  };
}

/// Pure codec for the small, on-device notification routing payload.
class NotificationDestinationCodec {
  NotificationDestinationCodec._();

  static String encode(NotificationDestination destination) {
    return switch (destination.type) {
      NotificationDestinationType.person => 'person:${destination.localId}',
      NotificationDestinationType.lifeEvent =>
        'life_event:${destination.localId}',
      NotificationDestinationType.profile => 'profile',
      NotificationDestinationType.lifeTimeline => 'life_timeline',
      NotificationDestinationType.milestone => 'milestone',
    };
  }

  static NotificationDestination? decode(String? payload) {
    final value = payload?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value == 'profile') {
      return const NotificationDestination.profile();
    }
    if (value.startsWith('life_event:')) {
      final id = value.substring('life_event:'.length);
      if (id.isEmpty ||
          id.length > 128 ||
          id.contains(':') ||
          id.contains('\n')) {
        return null;
      }
      return NotificationDestination.lifeEvent(id);
    }
    if (value == 'life_timeline') {
      return const NotificationDestination.lifeTimeline();
    }
    if (value == 'milestone') {
      return const NotificationDestination.milestone();
    }
    if (!value.startsWith('person:')) {
      return null;
    }
    final id = value.substring('person:'.length);
    if (id.isEmpty ||
        id.length > 128 ||
        id.contains(':') ||
        id.contains('\n')) {
      return null;
    }
    return NotificationDestination.person(id);
  }
}
