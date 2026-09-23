import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/engagement/engagement_action.dart';
import '../../../core/engagement/engagement_provider.dart';
import '../../age_calculator/domain/models/age_result.dart';
import '../utils/result_share_service.dart';

class ShareResultButton extends ConsumerWidget {
  const ShareResultButton({super.key, required this.result});

  final AgeResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () async {
        await HapticFeedback.selectionClick();
        if (!context.mounted) {
          return;
        }
        final format = await ResultShareService.shareResult(
          context: context,
          result: result,
        );
        ref
            .read(appAnalyticsProvider)
            .logEventSafely(
              AnalyticsEvent.ageResultShared,
              parameters: <String, Object>{'format': format.value},
            );
        ref
            .read(engagementTrackerProvider)
            .recordMeaningfulActionSafely(EngagementAction.share);
      },
      icon: const Icon(Icons.share_outlined),
      label: const Text('Share Result'),
    );
  }
}
