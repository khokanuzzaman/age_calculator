import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../profile/providers/primary_profile_provider.dart';
import '../models/life_event.dart';
import '../models/life_event_recurrence.dart';
import '../providers/life_events_provider.dart';
import 'life_event_detail_screen.dart';
import '../utils/life_event_share_service.dart';
import '../utils/life_event_utils.dart';
import '../widgets/life_event_editor_sheet.dart';

class LifeTimelineScreen extends ConsumerStatefulWidget {
  const LifeTimelineScreen({super.key});

  @override
  ConsumerState<LifeTimelineScreen> createState() => _LifeTimelineScreenState();
}

class _LifeTimelineScreenState extends ConsumerState<LifeTimelineScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.lifeTimelineOpened,
          parameters: const <String, Object>{'source': 'home'},
        );
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(lifeEventsProvider);
    final birthDate = ref.watch(
      primaryProfileProvider.select((profile) => profile?.birthDate),
    );
    final today = AppDateUtils.dateOnly(DateTime.now());
    final upcoming = events
        .where(
          (event) => LifeEventUtils.nextOccurrence(event, now: today) != null,
        )
        .toList(growable: false);
    final past = events
        .where(
          (event) =>
              event.recurrence == LifeEventRecurrence.none &&
              AppDateUtils.dateOnly(event.eventDate).isBefore(today),
        )
        .toList(growable: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Life Timeline')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref, birthDate),
        icon: const Icon(Icons.add),
        label: const Text('Add event'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: events.isEmpty
                ? const _EmptyState()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.huge * 2,
                    ),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        const _SectionTitle(
                          title: 'Upcoming',
                          icon: Icons.upcoming_outlined,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final event in upcoming) ...[
                          _LifeEventCard(
                            event: event,
                            birthDate: birthDate,
                            onTap: () => _openDetail(context, event),
                            onEdit: () => _edit(context, ref, event, birthDate),
                            onDelete: () => _delete(context, ref, event),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                      if (past.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        const _SectionTitle(
                          title: 'Past moments',
                          icon: Icons.history_outlined,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final event in past) ...[
                          _LifeEventCard(
                            event: event,
                            birthDate: birthDate,
                            onTap: () => _openDetail(context, event),
                            onEdit: () => _edit(context, ref, event, birthDate),
                            onDelete: () => _delete(context, ref, event),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    DateTime? birthDate,
  ) async {
    final event = await showLifeEventEditor(context, birthDate: birthDate);
    if (event != null) {
      await ref.read(lifeEventsProvider.notifier).addOrUpdate(event);
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.timelineEventAdded,
            parameters: <String, Object>{
              'reminder_enabled': event.reminderEnabled,
              'category': event.category.name,
              'recurrence': event.recurrence.name,
            },
          );
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.lifeEventCategorySelected,
            parameters: <String, Object>{'category': event.category.name},
          );
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.lifeEventReminderPreferencesChanged,
            parameters: <String, Object>{
              'enabled': event.reminderEnabled,
              'lead_count': event.reminderPreferences
                  .normalized(
                    recurring: event.recurrence == LifeEventRecurrence.yearly,
                  )
                  .length,
            },
          );
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
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
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.timelineEventUpdated,
            parameters: <String, Object>{
              'reminder_enabled': updated.reminderEnabled,
              'category': updated.category.name,
              'recurrence': updated.recurrence.name,
            },
          );
      if (event.category != updated.category) {
        ref
            .read(appAnalyticsProvider)
            .logEventSafely(
              AnalyticsEvent.lifeEventCategorySelected,
              parameters: <String, Object>{'category': updated.category.name},
            );
      }
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

  void _openDetail(BuildContext context, LifeEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LifeEventDetailScreen(eventId: event.id),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    LifeEvent event,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove event?'),
        content: Text('Remove “${event.title}” from your timeline?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await ref.read(lifeEventsProvider.notifier).remove(event.id);
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(AnalyticsEvent.timelineEventDeleted);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _LifeEventCard extends StatelessWidget {
  const _LifeEventCard({
    required this.event,
    required this.birthDate,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LifeEvent event;
  final DateTime? birthDate;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final details = LifeEventUtils.details(event, birthDate: birthDate);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'life-event-avatar:${event.id}',
            child: Material(
              color: Colors.transparent,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primaryContainer,
                child: Text(event.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM yyyy').format(event.eventDate),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (event.recurrence == LifeEventRecurrence.yearly)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      'Yearly · next ${DateFormat('d MMM yyyy').format(details.occurrenceDate ?? event.eventDate)}',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  details.relativeText,
                  style: textTheme.labelLarge?.copyWith(
                    color: details.isUpcoming ? scheme.primary : scheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  details.ageText,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Edit event',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Share event',
                onPressed: () => LifeEventShareService.shareEvent(
                  context: context,
                  event: event,
                  details: details,
                ),
                icon: const Icon(Icons.share_outlined),
              ),
              IconButton(
                tooltip: 'Remove',
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline_outlined, size: 64, color: scheme.primary),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Your timeline is empty',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add a graduation, first job, trip, anniversary, or any important moment to see it on your timeline.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your events stay on this device.',
              style: textTheme.labelMedium?.copyWith(color: scheme.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
