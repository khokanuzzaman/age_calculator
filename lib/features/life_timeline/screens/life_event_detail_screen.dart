import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_entrance.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../profile/providers/primary_profile_provider.dart';
import '../models/life_event.dart';
import '../models/life_event_recurrence.dart';
import '../providers/life_events_provider.dart';
import '../utils/life_event_share_service.dart';
import '../utils/life_event_utils.dart';
import '../widgets/life_event_editor_sheet.dart';

class LifeEventDetailScreen extends ConsumerStatefulWidget {
  const LifeEventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<LifeEventDetailScreen> createState() =>
      _LifeEventDetailScreenState();
}

class _LifeEventDetailScreenState extends ConsumerState<LifeEventDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(AnalyticsEvent.lifeEventDetailOpened);
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(
      lifeEventsProvider.select(
        (events) =>
            events.where((item) => item.id == widget.eventId).firstOrNull,
      ),
    );
    if (event == null) {
      return const Scaffold(body: Center(child: Text('Life event not found')));
    }

    final birthDate = ref.watch(
      primaryProfileProvider.select((profile) => profile?.birthDate),
    );
    final details = LifeEventUtils.details(event, birthDate: birthDate);
    final duration = LifeEventUtils.durationSince(event);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(event.title)),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                AppEntrance(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'life-event-avatar:${event.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Text(
                                event.emoji,
                                style: const TextStyle(fontSize: 36),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          event.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _DetailBadge(
                              icon: Icons.category_outlined,
                              label: event.category.label,
                            ),
                            _DetailBadge(
                              icon:
                                  event.recurrence == LifeEventRecurrence.yearly
                                  ? Icons.repeat_rounded
                                  : Icons.event_outlined,
                              label: event.recurrence.label,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          _statusText(event, details),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Started ${DateFormat('d MMMM yyyy').format(event.eventDate)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (event.recurrence == LifeEventRecurrence.yearly) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Next anniversary: ${DateFormat('d MMMM yyyy').format(details.occurrenceDate ?? event.eventDate)}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppEntrance(
                  delay: const Duration(milliseconds: 55),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Moment details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoLine(
                          label: 'Category',
                          value: event.category.label,
                        ),
                        if (duration != null)
                          _InfoLine(
                            label:
                                event.recurrence == LifeEventRecurrence.yearly
                                ? 'Time since moment'
                                : 'Time from today',
                            value:
                                '${duration.years} years, ${duration.months} months, ${duration.days} days',
                          ),
                        if (event.recurrence == LifeEventRecurrence.none)
                          _InfoLine(
                            label: 'Age context',
                            value: details.ageText,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppEntrance(
                  delay: const Duration(milliseconds: 105),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppPrimaryButton(
                        label: 'Edit Moment',
                        icon: Icons.edit_outlined,
                        onPressed: () => _edit(context, event, birthDate),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () => LifeEventShareService.shareEvent(
                          context: context,
                          event: event,
                          details: details,
                        ),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share Moment'),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _delete(context, event),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete Moment'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(LifeEvent event, LifeEventDetails details) {
    if (event.recurrence == LifeEventRecurrence.yearly) {
      final anniversary = LifeEventUtils.anniversaryLabel(
        details.anniversaryNumber ?? 0,
      );
      return details.isToday
          ? '$anniversary anniversary today'
          : '$anniversary anniversary ${details.relativeText.toLowerCase()}';
    }
    return details.relativeText;
  }

  Future<void> _edit(
    BuildContext context,
    LifeEvent event,
    DateTime? birthDate,
  ) async {
    final updated = await showLifeEventEditor(
      context,
      existing: event,
      birthDate: birthDate,
    );
    if (updated != null) {
      await ref.read(lifeEventsProvider.notifier).addOrUpdate(updated);
      if (event.recurrence != updated.recurrence) {
        ref
            .read(appAnalyticsProvider)
            .logEventSafely(
              AnalyticsEvent.lifeEventRecurrenceChanged,
              parameters: <String, Object>{
                'recurrence': updated.recurrence.name,
              },
            );
      }
      if (event.reminderPreferences != updated.reminderPreferences) {
        ref
            .read(appAnalyticsProvider)
            .logEventSafely(
              AnalyticsEvent.lifeEventReminderPreferencesChanged,
              parameters: <String, Object>{
                'enabled': updated.reminderEnabled,
                'lead_count': updated.reminderPreferences
                    .normalized(
                      recurring:
                          updated.recurrence == LifeEventRecurrence.yearly,
                    )
                    .length,
              },
            );
      }
    }
  }

  Future<void> _delete(BuildContext context, LifeEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete moment?'),
        content: Text('Delete “${event.title}” from your timeline?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(lifeEventsProvider.notifier).remove(event.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.md),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
