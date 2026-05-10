import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/animated_count_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../age_calculator/domain/models/age_result.dart';
import 'share_result_button.dart';

class ResultSummaryCard extends StatelessWidget {
  const ResultSummaryCard({
    super.key,
    required this.result,
    required this.onReset,
  });

  final AgeResult result;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your age',
            style: textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: _AgeValueBlock(
                  label: 'Years',
                  value: result.years,
                  highlight: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _AgeValueBlock(label: 'Months', value: result.months),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _AgeValueBlock(label: 'Days', value: result.days),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ChipInfo(
                      icon: Icons.today_outlined,
                      label: 'Total days',
                      value: result.totalDays,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ChipInfo(
                      icon: Icons.cake_outlined,
                      label: 'Next birthday in',
                      value: result.daysUntilNextBirthday,
                      suffix: ' days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _TextChipInfo(
                icon: Icons.calendar_month_outlined,
                label: 'Born on',
                value: result.dayOfWeekBorn,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(child: ShareResultButton(result: result)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await HapticFeedback.selectionClick();
                    onReset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recalculate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgeValueBlock extends StatelessWidget {
  const _AgeValueBlock({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final int value;
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
              duration: const Duration(milliseconds: 1000),
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

class _ChipInfo extends StatelessWidget {
  const _ChipInfo({
    required this.icon,
    required this.label,
    required this.value,
    this.suffix = '',
  });

  final IconData icon;
  final String label;
  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  AnimatedCountText(
                    value: value,
                    suffix: suffix,
                    formatter: (num n) =>
                        AppDateUtils.formatLargeInteger(n.round()),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextChipInfo extends StatelessWidget {
  const _TextChipInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
