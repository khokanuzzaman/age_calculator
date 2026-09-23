import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/engagement/engagement_action.dart';
import '../../../core/engagement/engagement_provider.dart';
import '../data/primary_profile_repository.dart';
import '../models/primary_profile.dart';

final primaryProfileRepositoryProvider = Provider<PrimaryProfileRepository>(
  (ref) => PrimaryProfileRepository(ref.watch(sharedPreferencesProvider)),
);

final primaryProfileProvider =
    NotifierProvider<PrimaryProfileNotifier, PrimaryProfile?>(
      PrimaryProfileNotifier.new,
    );

class PrimaryProfileNotifier extends Notifier<PrimaryProfile?> {
  @override
  PrimaryProfile? build() {
    return ref.read(primaryProfileRepositoryProvider).load();
  }

  Future<void> save({required DateTime birthDate, String? displayName}) async {
    final next = PrimaryProfile(
      birthDate: birthDate,
      displayName: displayName,
    ).normalized();
    final wasExisting = state != null;
    await ref.read(primaryProfileRepositoryProvider).save(next);
    state = next;
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          wasExisting
              ? AnalyticsEvent.primaryProfileUpdated
              : AnalyticsEvent.primaryProfileSaved,
        );
    try {
      ref
          .read(engagementTrackerProvider)
          .recordMeaningfulActionSafely(EngagementAction.profile);
    } catch (_) {
      // Engagement tracking is optional and never blocks a local save.
    }
  }

  Future<void> clear() async {
    if (state == null) {
      return;
    }
    await ref.read(primaryProfileRepositoryProvider).clear();
    state = null;
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(AnalyticsEvent.primaryProfileCleared);
  }
}
