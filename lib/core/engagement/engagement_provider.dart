import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/app_analytics_provider.dart';
import '../app_info/app_info_service.dart';
import '../app_info/app_info_provider.dart';
import '../../app/theme/theme_mode_notifier.dart';
import 'engagement_repository.dart';
import 'engagement_tracker.dart';
import 'review_gateway.dart';

final engagementRepositoryProvider = Provider<EngagementRepository>((ref) {
  return EngagementRepository(ref.watch(sharedPreferencesProvider));
});

final reviewGatewayProvider = Provider<ReviewGateway>(
  (_) => InAppReviewGateway(),
);

final engagementTrackerProvider = Provider<EngagementTracker>((ref) {
  return EngagementTracker(
    repository: ref.watch(engagementRepositoryProvider),
    reviewGateway: ref.watch(reviewGatewayProvider),
    analytics: ref.watch(appAnalyticsProvider),
    appVersionLoader: () async {
      final version = await ref.read(appVersionProvider.future);
      return version == AppInfoService.unavailableVersion ? 'unknown' : version;
    },
  );
});
