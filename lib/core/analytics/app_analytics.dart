import 'dart:async';

import 'analytics_event.dart';

typedef AnalyticsParameters = Map<String, Object>;

/// Vendor-independent analytics contract for the app.
abstract interface class AppAnalytics {
  Future<void> logEvent(
    AnalyticsEvent event, {
    AnalyticsParameters parameters = const <String, Object>{},
  });
}

/// Sends an event without making product actions wait for analytics.
///
/// Implementations may later call a remote vendor and fail. Those failures are
/// deliberately swallowed here so analytics can never block the app.
extension AppAnalyticsBestEffort on AppAnalytics {
  void logEventSafely(
    AnalyticsEvent event, {
    AnalyticsParameters parameters = const <String, Object>{},
  }) {
    try {
      unawaited(logEvent(event, parameters: parameters).catchError((_) {}));
    } catch (_) {
      // Analytics must never affect the user action that triggered it.
    }
  }
}
