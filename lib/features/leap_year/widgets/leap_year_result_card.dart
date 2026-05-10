import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_stat_tile.dart';
import '../../leap_year/utils/leap_year_utils.dart';

class LeapYearResultCard extends StatelessWidget {
  const LeapYearResultCard({super.key, required this.result});

  final LeapYearResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = result.isLeapYear ? scheme.primary : scheme.tertiary;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                result.isLeapYear
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: statusColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  result.isLeapYear
                      ? '${result.year} is a leap year'
                      : '${result.year} is not a leap year',
                  style: textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          AppStatTile(
            label: 'Previous leap year',
            value: result.previousLeapYear == null
                ? 'Not available'
                : AppDateUtils.formatLargeInteger(result.previousLeapYear!),
            icon: Icons.skip_previous_outlined,
          ),
          AppStatTile(
            label: 'Next leap year',
            value: result.nextLeapYear == null
                ? 'Not available'
                : AppDateUtils.formatLargeInteger(result.nextLeapYear!),
            icon: Icons.skip_next_outlined,
          ),
          AppStatTile(
            label: 'Days in February',
            value: '${result.daysInFebruary} days',
            icon: Icons.calendar_month_outlined,
          ),
        ],
      ),
    );
  }
}
