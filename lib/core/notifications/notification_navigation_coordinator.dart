import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../features/life_timeline/screens/life_event_detail_screen.dart';
import '../../features/saved_birthdays/screens/person_detail_screen.dart';
import 'notification_destination.dart';

typedef NotificationOpened = void Function(NotificationDestination destination);

/// Queues notification destinations until the app's navigator exists.
class NotificationNavigationCoordinator {
  NotificationNavigationCoordinator({GlobalKey<NavigatorState>? navigatorKey})
    : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();

  static final instance = NotificationNavigationCoordinator();

  final GlobalKey<NavigatorState> navigatorKey;
  NotificationDestination? _pending;
  String? _lastPayload;
  NotificationOpened? onOpened;

  void handlePayload(String? payload) {
    final value = payload?.trim();
    if (value == null || value.isEmpty || value == _lastPayload) {
      return;
    }
    final destination = NotificationDestinationCodec.decode(value);
    if (destination == null) {
      return;
    }
    _lastPayload = value;
    _pending = destination;
    flush();
  }

  void flush() {
    final destination = _pending;
    final navigator = navigatorKey.currentState;
    if (destination == null || navigator == null) {
      return;
    }
    _pending = null;
    onOpened?.call(destination);
    switch (destination.type) {
      case NotificationDestinationType.person:
        final id = destination.localId;
        if (id != null) {
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => PersonDetailScreen(personId: id),
            ),
          );
        }
      case NotificationDestinationType.lifeEvent:
        final id = destination.localId;
        if (id != null) {
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => LifeEventDetailScreen(eventId: id),
            ),
          );
        }
      case NotificationDestinationType.profile:
        navigator.pushNamed(AppRoutes.profile);
      case NotificationDestinationType.lifeTimeline:
        navigator.pushNamed(AppRoutes.lifeTimeline);
      case NotificationDestinationType.milestone:
        navigator.pushNamed(AppRoutes.ageCalculator);
    }
  }
}

final notificationNavigationCoordinator =
    NotificationNavigationCoordinator.instance;
