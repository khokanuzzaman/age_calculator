import 'analytics_event.dart';
import 'app_analytics.dart';

/// Safe default until a privacy-reviewed analytics provider is configured.
class NoopAnalytics implements AppAnalytics {
  const NoopAnalytics();

  @override
  Future<void> logEvent(
    AnalyticsEvent event, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {}
}
