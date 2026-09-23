import 'analytics_event.dart';

typedef AnalyticsParameters = Map<String, Object?>;

/// Vendor-independent analytics contract for the app.
abstract interface class AppAnalytics {
  Future<void> logEvent(
    AnalyticsEvent event, {
    AnalyticsParameters parameters = const <String, Object?>{},
  });
}
