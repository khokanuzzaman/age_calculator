import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../utils/life_insights_utils.dart';

/// Generation + birth season, shown on the Overview tab.
class LifeInsightsCard extends StatelessWidget {
  const LifeInsightsCard({super.key, required this.birthDate});

  final DateTime birthDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final generation = LifeInsightsUtils.generation(birthDate.year);
    final season = LifeInsightsUtils.birthSeason(birthDate.month);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('About Your Birth', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _InsightRow(
            icon: Icons.groups_2_outlined,
            label: 'Generation',
            value: generation,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InsightRow(
            icon: Icons.wb_sunny_outlined,
            label: 'Birth season',
            value: season,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Season shown for the northern hemisphere.',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The next 10 birthdays, shown on the Milestones tab.
class UpcomingBirthdaysCard extends StatelessWidget {
  const UpcomingBirthdaysCard({super.key, required this.birthDate});

  final DateTime birthDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final items = LifeInsightsUtils.upcomingBirthdays(
      birthDate,
      DateTime.now(),
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Upcoming Birthdays', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Turning ${item.turningAge}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${DateFormat('d MMM yyyy').format(item.date)} · '
                        '${item.weekday}',
                        style: textTheme.bodySmall,
                      ),
                      Text(
                        item.daysAway == 0
                            ? 'Today'
                            : 'in ${AppDateUtils.formatLargeInteger(item.daysAway)} days',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Life-stage milestones (18, 21, 30 ... 65), shown on the Milestones tab.
class LifeStagesCard extends StatelessWidget {
  const LifeStagesCard({super.key, required this.birthDate});

  final DateTime birthDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final items = LifeInsightsUtils.lifeStageMilestones(
      birthDate,
      DateTime.now(),
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Life Stages', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    item.reached
                        ? Icons.check_circle_outline
                        : Icons.hourglass_empty,
                    size: 18,
                    color: item.reached ? scheme.primary : scheme.tertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${item.label} (${item.age})',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('d MMM yyyy').format(item.date),
                        style: textTheme.bodySmall,
                      ),
                      Text(
                        item.reached
                            ? 'Reached'
                            : item.remainingDays == 0
                            ? 'Today'
                            : 'in ${AppDateUtils.formatLargeInteger(item.remainingDays)} days',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
