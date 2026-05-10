import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/animated_count_text.dart';
import '../../../shared/widgets/animated_progress_bar.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_stat_tile.dart';
import '../models/age_milestone_model.dart';

class LifeStatsCard extends StatelessWidget {
  const LifeStatsCard({super.key, required this.stats});

  final LifeStats stats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Life Stats', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.base),
          AppStatTile(
            label: 'Total days lived',
            valueWidget: AnimatedCountText(
              value: stats.totalDays,
              formatter: (n) => AppDateUtils.formatLargeInteger(n.round()),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: Icons.today_outlined,
          ),
          AppStatTile(
            label: 'Total hours lived',
            valueWidget: AnimatedCountText(
              value: stats.totalHours,
              formatter: (n) => AppDateUtils.formatLargeInteger(n.round()),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: Icons.access_time,
          ),
          AppStatTile(
            label: 'Total minutes lived',
            valueWidget: AnimatedCountText(
              value: stats.totalMinutes,
              formatter: (n) => AppDateUtils.formatLargeInteger(n.round()),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: Icons.timer_outlined,
          ),
          AppStatTile(
            label: 'Total seconds lived',
            valueWidget: AnimatedCountText(
              value: stats.totalSeconds,
              formatter: (n) => AppDateUtils.formatLargeInteger(n.round()),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: Icons.hourglass_bottom,
          ),
          const SizedBox(height: AppSpacing.base),
          _ProgressRow(label: 'Year completed', value: stats.yearProgress),
          const SizedBox(height: AppSpacing.sm),
          _ProgressRow(label: 'Month completed', value: stats.monthProgress),
          const SizedBox(height: AppSpacing.sm),
          _ProgressRow(label: 'Week completed', value: stats.weekProgress),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final normalized = (value / 100).clamp(0, 1).toDouble();

    return AnimatedProgressBar(
      label: label,
      value: normalized,
      duration: const Duration(milliseconds: 1000),
    );
  }
}
