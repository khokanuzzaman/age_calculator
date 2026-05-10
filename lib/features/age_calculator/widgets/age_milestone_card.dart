import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/animated_count_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/age_milestone_model.dart';

class AgeMilestoneCard extends StatelessWidget {
  const AgeMilestoneCard({super.key, required this.milestones});

  final List<AgeMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Upcoming Milestones', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (milestones.isEmpty)
            Text(
              'No upcoming milestones available right now.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            ...milestones.map(
              (milestone) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MilestoneTile(milestone: milestone),
              ),
            ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.milestone});

  final AgeMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              milestone.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              DateFormat('d MMMM yyyy').format(milestone.targetDate),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text(
                  'Remaining: ',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                AnimatedCountText(
                  value: milestone.remainingDays,
                  formatter: (n) => AppDateUtils.formatLargeInteger(n.round()),
                  suffix: ' days',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                  duration: const Duration(milliseconds: 1000),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
