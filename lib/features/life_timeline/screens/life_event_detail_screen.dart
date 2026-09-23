import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
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
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(event.emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(DateFormat('d MMMM yyyy').format(event.eventDate)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _statusText(event, details),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (event.recurrence == LifeEventRecurrence.yearly) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Next anniversary: ${DateFormat('d MMMM yyyy').format(details.occurrenceDate ?? event.eventDate)}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moment details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoLine(label: 'Category', value: event.category.label),
                      _InfoLine(label: 'Repeat', value: event.recurrence.label),
                      if (duration != null)
                        _InfoLine(
                          label: event.recurrence == LifeEventRecurrence.yearly
                              ? 'Time since moment'
                              : 'Time from today',
                          value:
                              '${duration.years} years, ${duration.months} months, ${duration.days} days',
                        ),
                      if (event.recurrence == LifeEventRecurrence.none)
                        _InfoLine(label: 'Age context', value: details.ageText),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () => _delete(context, event),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Moment'),
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
