import 'package:age_calculator/core/analytics/analytics_event.dart';
import 'package:age_calculator/core/engagement/engagement_action.dart';
import 'package:age_calculator/core/engagement/engagement_repository.dart';
import 'package:age_calculator/core/engagement/engagement_tracker.dart';
import 'package:age_calculator/core/engagement/review_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_app_analytics.dart';

class _FakeReviewGateway implements ReviewGateway {
  _FakeReviewGateway({this.available = true, this.throwOnRequest = false});

  bool available;
  bool throwOnRequest;
  int requestCount = 0;
  int storeListingCount = 0;
  String? storeListingAppStoreId;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    requestCount++;
    if (throwOnRequest) throw StateError('review unavailable');
  }

  @override
  Future<void> openStoreListing({String? appStoreId}) async {
    storeListingCount++;
    storeListingAppStoreId = appStoreId;
  }
}

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('first day is never eligible', () async {
    final prefs = await prefsWith({
      'engagement_first_seen_date': '2026-09-23',
      'engagement_meaningful_action_count': 5,
      'engagement_action_categories': ['age', 'profile'],
    });
    expect(
      EngagementRepository(
        prefs,
      ).isEligible(now: DateTime(2026, 9, 23), appVersion: '1.4.0 (10)'),
      isFalse,
    );
  });

  test(
    'five actions and two categories become eligible on day three',
    () async {
      final prefs = await prefsWith({
        'engagement_first_seen_date': '2026-09-20',
        'engagement_meaningful_action_count': 5,
        'engagement_action_categories': ['age', 'date_tools'],
      });
      expect(
        EngagementRepository(
          prefs,
        ).isEligible(now: DateTime(2026, 9, 23), appVersion: '1.4.0 (10)'),
        isTrue,
      );
    },
  );

  test(
    'version, cooldown, and automatic attempt limits are enforced',
    () async {
      final prefs = await prefsWith({
        'engagement_first_seen_date': '2026-01-01',
        'engagement_meaningful_action_count': 5,
        'engagement_action_categories': ['age', 'profile'],
        'engagement_last_review_prompt_date': '2026-09-01',
        'engagement_review_prompt_count': 1,
        'engagement_last_prompted_app_version': '1.4.0 (10)',
      });
      final repository = EngagementRepository(prefs);
      expect(
        repository.isEligible(
          now: DateTime(2026, 9, 23),
          appVersion: '1.4.0 (10)',
        ),
        isFalse,
      );
      expect(
        repository.isEligible(
          now: DateTime(2026, 12, 30),
          appVersion: '1.4.0 (11)',
        ),
        isTrue,
      );
      await repository.markReviewPromptRequested(
        date: DateTime(2026, 12, 30),
        appVersion: '1.4.0 (11)',
      );
      expect(
        repository.isEligible(
          now: DateTime(2027, 12, 31),
          appVersion: '1.4.0 (12)',
        ),
        isFalse,
      );
    },
  );

  test(
    'tracker requests native review only after an eligible action',
    () async {
      final prefs = await prefsWith({
        'engagement_first_seen_date': '2026-09-20',
        'engagement_meaningful_action_count': 4,
        'engagement_action_categories': ['age', 'profile'],
      });
      final gateway = _FakeReviewGateway();
      final analytics = FakeAppAnalytics();
      final tracker = EngagementTracker(
        repository: EngagementRepository(prefs),
        reviewGateway: gateway,
        analytics: analytics,
        appVersionLoader: () async => '1.4.0 (10)',
        now: () => DateTime(2026, 9, 23),
      );
      await tracker.recordMeaningfulAction(EngagementAction.age);
      expect(gateway.requestCount, 1);
      expect(
        analytics.events.single.event,
        AnalyticsEvent.ratingPromptRequested,
      );
      expect(analytics.events.single.parameters, {'trigger_category': 'age'});
    },
  );

  test(
    'review failure and unavailable review never throws or changes action count',
    () async {
      for (final gateway in [
        _FakeReviewGateway(available: false),
        _FakeReviewGateway(throwOnRequest: true),
      ]) {
        final prefs = await prefsWith({
          'engagement_first_seen_date': '2026-09-20',
          'engagement_meaningful_action_count': 4,
          'engagement_action_categories': ['age', 'profile'],
        });
        final tracker = EngagementTracker(
          repository: EngagementRepository(prefs),
          reviewGateway: gateway,
          analytics: FakeAppAnalytics(),
          appVersionLoader: () async => '1.4.0 (10)',
          now: () => DateTime(2026, 9, 23),
        );
        await tracker.recordMeaningfulAction(EngagementAction.dateTools);
        expect(EngagementRepository(prefs).load().meaningfulActionCount, 5);
      }
    },
  );

  test(
    'explicit store listing action can target the iOS app store id',
    () async {
      final gateway = _FakeReviewGateway();
      await gateway.openStoreListing(appStoreId: '6802000455');
      expect(gateway.storeListingCount, 1);
      expect(gateway.storeListingAppStoreId, '6802000455');
    },
  );
}
