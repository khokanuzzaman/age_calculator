import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_stat_tile.dart';
import '../../domain/models/age_result.dart';

class AgeResultCard extends StatelessWidget {
  const AgeResultCard({super.key, required this.result, required this.onReset});

  final AgeResult result;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.98, end: 1),
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroAgeDisplay(result: result),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _AgeStats(result: result),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () async {
                await HapticFeedback.selectionClick();
                onReset();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroAgeDisplay extends StatelessWidget {
  const _HeroAgeDisplay({required this.result});

  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final semanticAgeLabel =
        '${AppDateUtils.formatLargeInteger(result.years)} '
        '${_unitLabel(result.years, 'year')}, '
        '${AppDateUtils.formatLargeInteger(result.months)} '
        '${_unitLabel(result.months, 'month')}, '
        '${AppDateUtils.formatLargeInteger(result.days)} '
        '${_unitLabel(result.days, 'day')} old';

    return Semantics(
      container: true,
      label: semanticAgeLabel,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your age',
              style: textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                _AnimatedIntText(
                  value: result.years,
                  style: textTheme.displayLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    _unitLabel(result.years, 'year'),
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _AgePart(value: result.months, unit: 'month'),
                _AgePart(value: result.days, unit: 'day'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgePart extends StatelessWidget {
  const _AgePart({required this.value, required this.unit});

  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedIntText(
          value: value,
          style: textTheme.headlineSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          ' ${_unitLabel(value, unit)}',
          style: textTheme.headlineSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AgeStats extends StatelessWidget {
  const _AgeStats({required this.result});

  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatTileShell(
          child: AppStatTile(
            label: 'Total days lived',
            valueWidget: _AnimatedIntText(
              value: result.totalDays,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            icon: Icons.today_outlined,
          ),
        ),
        _StatTileShell(
          child: AppStatTile(
            label: 'Total hours lived',
            valueWidget: _AnimatedIntText(
              value: result.totalHours,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            icon: Icons.access_time,
          ),
        ),
        _StatTileShell(
          child: AppStatTile(
            label: 'Total minutes lived',
            valueWidget: _AnimatedIntText(
              value: result.totalMinutes,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            icon: Icons.timer_outlined,
          ),
        ),
        _StatTileShell(
          child: AppStatTile(
            label: 'Days until next birthday',
            valueWidget: _AnimatedIntText(
              value: result.daysUntilNextBirthday,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            icon: Icons.cake_outlined,
          ),
        ),
        _StatTileShell(
          child: AppStatTile(
            label: 'Born on',
            value: result.dayOfWeekBorn,
            icon: Icons.calendar_month_outlined,
          ),
        ),
      ],
    );
  }
}

class _AnimatedIntText extends StatelessWidget {
  const _AnimatedIntText({required this.value, this.style});

  final int value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(
          AppDateUtils.formatLargeInteger(animatedValue.round()),
          style: style,
        );
      },
    );
  }
}

class _StatTileShell extends StatelessWidget {
  const _StatTileShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerHigh,
              scheme.secondaryContainer.withValues(alpha: 0.35),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}

String _unitLabel(int value, String singular) {
  return value == 1 ? singular : '${singular}s';
}
