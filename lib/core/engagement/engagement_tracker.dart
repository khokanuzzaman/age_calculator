import 'dart:async';

import '../analytics/analytics_event.dart';
import '../analytics/app_analytics.dart';
import 'engagement_action.dart';
import 'engagement_repository.dart';
import 'review_gateway.dart';

typedef AppVersionLoader = Future<String> Function();

class EngagementTracker {
  EngagementTracker({
    required EngagementRepository repository,
    required ReviewGateway reviewGateway,
    required AppAnalytics analytics,
    required AppVersionLoader appVersionLoader,
    DateTime Function()? now,
  }) : _repository = repository,
       _reviewGateway = reviewGateway,
       _analytics = analytics,
       _appVersionLoader = appVersionLoader,
       _now = now ?? DateTime.now;

  final EngagementRepository _repository;
  final ReviewGateway _reviewGateway;
  final AppAnalytics _analytics;
  final AppVersionLoader _appVersionLoader;
  final DateTime Function() _now;
  bool _reviewRequestInProgress = false;

  Future<void> recordMeaningfulAction(EngagementAction action) async {
    await _repository.record(action, now: _now());
    await _maybeRequestReview(action);
  }

  Future<void> _maybeRequestReview(EngagementAction action) async {
    if (_reviewRequestInProgress) {
      return;
    }
    _reviewRequestInProgress = true;
    try {
      final version = await _appVersionLoader();
      if (!EngagementRepository.isValidSemanticVersion(version)) {
        return;
      }
      final now = _now();
      if (!_repository.isEligible(now: now, appVersion: version)) {
        return;
      }
      if (!await _reviewGateway.isAvailable()) {
        return;
      }
      await _reviewGateway.requestReview();
      await _repository.markReviewPromptRequested(
        date: now,
        appVersion: version,
      );
      _analytics.logEventSafely(
        AnalyticsEvent.ratingPromptRequested,
        parameters: <String, Object>{'trigger_category': action.analyticsValue},
      );
    } catch (_) {
      // A review prompt is best-effort and must never affect the completed action.
    } finally {
      _reviewRequestInProgress = false;
    }
  }

  void recordMeaningfulActionSafely(EngagementAction action) {
    unawaited(recordMeaningfulAction(action).catchError((_) {}));
  }
}
