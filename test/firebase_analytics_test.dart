import 'package:age_calculator/core/analytics/analytics_event.dart';
import 'package:age_calculator/core/analytics/app_analytics.dart';
import 'package:age_calculator/core/analytics/firebase_app_analytics.dart';
import 'package:age_calculator/core/analytics/noop_analytics.dart';
import 'package:age_calculator/core/firebase/firebase_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps event names and forwards safe parameters', () async {
    String? name;
    Map<String, Object>? capturedParameters;
    final analytics = FirebaseAppAnalytics(
      logger: (eventName, {Map<String, Object>? parameters}) async {
        name = eventName;
        capturedParameters = parameters;
      },
    );

    await analytics.logEvent(
      AnalyticsEvent.ageCalculated,
      parameters: {'source': 'age_calculator', 'enabled': true},
    );

    expect(name, 'age_calculated');
    expect(capturedParameters, {'source': 'age_calculator', 'enabled': true});
  });

  test('does not pass an empty parameter map to Firebase', () async {
    Map<String, Object>? capturedParameters = {'unexpected': true};
    final analytics = FirebaseAppAnalytics(
      logger: (eventName, {Map<String, Object>? parameters}) async {
        capturedParameters = parameters;
      },
    );

    await analytics.logEvent(AnalyticsEvent.appOpen);

    expect(capturedParameters, isNull);
  });

  test('best-effort logging swallows provider failures', () async {
    final analytics = FirebaseAppAnalytics(
      logger: (eventName, {Map<String, Object>? parameters}) async {
        throw StateError('analytics unavailable');
      },
    );

    expect(
      () => analytics.logEventSafely(AnalyticsEvent.appShareClicked),
      returnsNormally,
    );
    await Future<void>.delayed(Duration.zero);
  });

  test('startup fallback keeps the no-op provider available', () {
    const startup = FirebaseStartup.fallback();

    expect(startup.analytics, isA<NoopAnalytics>());
  });

  test(
    'startup selection uses Firebase only after initialization succeeds',
    () {
      expect(
        FirebaseBootstrap.analyticsForInitialization(firebaseInitialized: true),
        isA<FirebaseAppAnalytics>(),
      );
      expect(
        FirebaseBootstrap.analyticsForInitialization(
          firebaseInitialized: false,
        ),
        isA<NoopAnalytics>(),
      );
    },
  );
}
