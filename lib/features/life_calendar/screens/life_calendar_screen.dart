import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app_routes.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../life_timeline/providers/life_events_provider.dart';
import '../../profile/providers/primary_profile_provider.dart';
import '../models/life_calendar_model.dart';
import '../providers/life_calendar_provider.dart';
import '../utils/life_calendar_share_service.dart';
import '../utils/life_calendar_utils.dart';

class LifeCalendarScreen extends ConsumerStatefulWidget {
  const LifeCalendarScreen({super.key});

  @override
  ConsumerState<LifeCalendarScreen> createState() => _LifeCalendarScreenState();
}

class _LifeCalendarScreenState extends ConsumerState<LifeCalendarScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.lifeCalendarOpened,
          parameters: const <String, Object>{'source': 'home'},
        );
  }

  @override
  Widget build(BuildContext context) {
    final birthDate = ref.watch(
      primaryProfileProvider.select((profile) => profile?.birthDate),
    );
    final horizon = ref.watch(lifeCalendarHorizonProvider);
    final events = ref.watch(lifeEventsProvider);

    if (birthDate == null) {
      return const _MissingBirthdayScreen();
    }

    final summary = LifeCalendarUtils.buildSummary(
      birthDate: birthDate,
      horizonYears: horizon,
      events: events,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Life Calendar'),
        actions: [
          IconButton(
            tooltip: 'Share life calendar',
            onPressed: () => LifeCalendarShareService.shareCalendar(
              context: context,
              summary: summary,
            ),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: Column(
              children: [
                _SummaryCard(summary: summary),
                _HorizonPicker(
                  value: horizon,
                  onChanged: (value) => ref
                      .read(lifeCalendarHorizonProvider.notifier)
                      .setHorizon(value),
                ),
                const _Legend(),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.sm,
                      AppSpacing.base,
                      AppSpacing.xl,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 52,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                    itemCount: summary.weeks.length,
                    itemBuilder: (context, index) {
                      final week = summary.weeks[index];
                      return _WeekCell(
                        week: week,
                        onTap: () => _showWeek(context, week),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWeek(BuildContext context, LifeCalendarWeek week) async {
    final endDate = week.endDate;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          0,
          AppSpacing.base,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Week ${week.index + 1}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${DateFormat('d MMM yyyy').format(week.startDate)} – ${DateFormat('d MMM yyyy').format(endDate)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              week.isCurrent
                  ? 'This is your current week.'
                  : week.isLived
                  ? 'This week is part of your lived journey.'
                  : 'This week is ahead in your visual horizon.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (week.hasEvents) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Life events',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final event in week.events)
                Text('${event.emoji} ${event.title}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final LifeCalendarSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your life in weeks', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${AppDateUtils.formatLargeInteger(summary.completedWeeks)} weeks lived',
              style: textTheme.headlineSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              summary.currentAge.compactText,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizonPicker extends StatelessWidget {
  const _HorizonPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 80, label: Text('80 years')),
          ButtonSegment(value: 90, label: Text('90 years')),
          ButtonSegment(value: 100, label: Text('100 years')),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
        showSelectedIcon: false,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: scheme.primary, label: 'Lived'),
          const SizedBox(width: AppSpacing.md),
          _LegendItem(color: scheme.tertiary, label: 'Now'),
          const SizedBox(width: AppSpacing.md),
          _LegendItem(color: scheme.secondary, label: 'Event'),
          const SizedBox(width: AppSpacing.md),
          _LegendItem(color: scheme.surfaceContainerHighest, label: 'Ahead'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const SizedBox(width: 8, height: 8),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _WeekCell extends StatelessWidget {
  const _WeekCell({required this.week, required this.onTap});

  final LifeCalendarWeek week;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = week.hasEvents
        ? scheme.secondary
        : week.isCurrent
        ? scheme.tertiary
        : week.isLived
        ? scheme.primary
        : scheme.surfaceContainerHighest;
    return Semantics(
      button: true,
      label: 'Week ${week.index + 1}',
      child: Tooltip(
        message: 'Week ${week.index + 1}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: week.isCurrent
                  ? Border.all(color: scheme.onTertiary, width: 1)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingBirthdayScreen extends StatelessWidget {
  const _MissingBirthdayScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Life Calendar')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 64,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    'Set your birthday first',
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your life calendar needs your date of birth to map your weeks.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    label: 'Set My Birthday',
                    icon: Icons.cake_outlined,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
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
