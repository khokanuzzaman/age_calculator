import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_event.dart';
import 'app_analytics.dart';

typedef FirebaseEventLogger =
    Future<void> Function(String name, {Map<String, Object>? parameters});

/// Firebase-backed implementation of the vendor-independent analytics API.
class FirebaseAppAnalytics implements AppAnalytics {
  FirebaseAppAnalytics({FirebaseEventLogger? logger})
    : _logger = logger ?? _logWithFirebase;

  final FirebaseEventLogger _logger;

  static Future<void> _logWithFirebase(
    String name, {
    Map<String, Object>? parameters,
  }) {
    return FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  @override
  Future<void> logEvent(
    AnalyticsEvent event, {
    AnalyticsParameters parameters = const <String, Object>{},
  }) {
    return _logger(
      event.name,
      parameters: parameters.isEmpty ? null : parameters,
    );
  }
}
