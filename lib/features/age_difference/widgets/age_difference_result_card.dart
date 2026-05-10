import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/animated_count_text.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_stat_tile.dart';
import '../utils/age_difference_utils.dart';

class AgeDifferenceResultCard extends StatelessWidget {
  const AgeDifferenceResultCard({super.key, required this.result});

  final AgeDifferenceResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result.isSameAge) ...[
            Row(
              children: [
                Icon(Icons.people_alt_outlined, color: scheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Both have the same age', style: textTheme.titleMedium),
              ],
            ),
          ] else ...[
            Text(
              '${result.olderLabel} is older by',
              style: textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  value: result.years,
                  label: 'Years',
                  highlight: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricBlock(value: result.months, label: 'Months'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricBlock(value: result.days, label: 'Days'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          AppStatTile(
            label: 'Total difference',
            valueWidget: AnimatedCountText(
              value: result.totalDays,
              suffix: ' days',
              formatter: (value) =>
                  AppDateUtils.formatLargeInteger(value.round()),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: Icons.schedule_outlined,
          ),
          AppStatTile(
            label: 'Approx. total months',
            value: AppDateUtils.formatLargeInteger(result.totalMonths),
            icon: Icons.calendar_month_outlined,
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final int value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlight
            ? scheme.primaryContainer
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            AnimatedCountText(
              value: value,
              style: textTheme.headlineSmall?.copyWith(
                color: highlight ? scheme.onPrimaryContainer : scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: highlight
                    ? scheme.onPrimaryContainer.withValues(alpha: 0.85)
                    : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
