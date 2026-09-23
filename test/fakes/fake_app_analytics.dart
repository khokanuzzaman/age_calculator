import 'package:age_calculator/core/analytics/analytics_event.dart';
import 'package:age_calculator/core/analytics/app_analytics.dart';

class RecordedAnalyticsEvent {
  const RecordedAnalyticsEvent(this.event, this.parameters);

  final AnalyticsEvent event;
  final AnalyticsParameters parameters;
}

class FakeAppAnalytics implements AppAnalytics {
  final events = <RecordedAnalyticsEvent>[];

  @override
  Future<void> logEvent(
    AnalyticsEvent event, {
    AnalyticsParameters parameters = const <String, Object>{},
  }) async {
    events.add(RecordedAnalyticsEvent(event, {...parameters}));
  }
}
