import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/historical_event_model.dart';
import '../providers/historical_event_provider.dart';

class HistoryOnThisDayCard extends ConsumerWidget {
  const HistoryOnThisDayCard({super.key, required this.monthDay});

  final String monthDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(historicalEventsProvider(monthDay));
    final locale = ref.watch(appLocaleProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.history_edu_outlined, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('History on This Day', style: textTheme.titleLarge),
                    Text(
                      'Important events from your selected date',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => ref
                    .read(historicalEventsProvider(monthDay).notifier)
                    .refresh(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          asyncEvents.when(
            data: (events) {
              if (events.isEmpty) {
                return const _InfoState(
                  icon: Icons.info_outline,
                  text: 'No data found for this date.',
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < events.length; i++) ...[
                    _TimelineTile(
                      event: events[i],
                      regionLabel: locale.regionLabel,
                      isRegional: events[i].isRegional(locale.languageCode),
                    ),
                    if (i != events.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: _InfoState(
                icon: Icons.hourglass_top_rounded,
                text: 'Loading historical information...',
              ),
            ),
            error: (_, _) => const _InfoState(
              icon: Icons.wifi_off_outlined,
              text: 'Historical information is not available right now.',
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.event,
    required this.regionLabel,
    required this.isRegional,
  });

  final HistoricalEvent event;
  final String regionLabel;
  final bool isRegional;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                event.year?.toString() ?? 'N/A',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SourceBadge(
                        isRegional: isRegional,
                        regionLabel: regionLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    event.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      event.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (event.pageUrl != null && event.pageUrl!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: () => _openLink(context, event.pageUrl!),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Read more'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Could not open link')));
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.isRegional, required this.regionLabel});

  final bool isRegional;
  final String regionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = isRegional ? regionLabel : 'Global';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isRegional
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isRegional
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ],
    );
  }
}
