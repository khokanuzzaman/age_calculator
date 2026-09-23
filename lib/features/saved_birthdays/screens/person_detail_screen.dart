import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/app_store_links.dart';
import '../../../core/sharing/share_engine.dart';
import '../../../core/sharing/share_payload.dart';
import '../../../core/sharing/share_result.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../age_difference/utils/age_difference_utils.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../../age_calculator/utils/zodiac_utils.dart';
import '../../profile/providers/primary_profile_provider.dart';
import '../../birthday_wishes/utils/birthday_share_service.dart';
import '../../birthday_wishes/widgets/birthday_wish_composer_sheet.dart';
import '../models/saved_person.dart';
import '../providers/saved_birthdays_provider.dart';
import '../widgets/person_editor_sheet.dart';

class PersonDetailScreen extends ConsumerStatefulWidget {
  const PersonDetailScreen({super.key, required this.personId});

  final String personId;

  @override
  ConsumerState<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends ConsumerState<PersonDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(AnalyticsEvent.personDetailOpened);
  }

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(
      savedBirthdaysProvider.select(
        (people) =>
            people.where((item) => item.id == widget.personId).firstOrNull,
      ),
    );
    if (person == null) {
      return const Scaffold(body: Center(child: Text('Person not found')));
    }

    return _PersonDetailBody(person: person);
  }
}

class _PersonDetailBody extends ConsumerWidget {
  const _PersonDetailBody({required this.person});

  final SavedPerson person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final details = AgeCalculationUtils.birthdayDetails(person.birthDate, now);
    final age = person.ageInYears(now);
    final profile = ref.watch(primaryProfileProvider);
    final difference = profile == null
        ? null
        : AgeDifferenceUtils.calculate(
            personOneBirthDate: profile.birthDate,
            personTwoBirthDate: person.birthDate,
          );
    final days = details.daysUntilNextBirthday;
    final turns = age + (days == 0 ? 0 : 1);
    final countdown = days == 0
        ? 'Birthday is today!'
        : 'Turns $turns in $days ${days == 1 ? 'day' : 'days'}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(person.name),
        actions: [
          IconButton(
            tooltip: person.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
            onPressed: () => ref
                .read(savedBirthdaysProvider.notifier)
                .toggleFavorite(person.id),
            icon: Icon(person.isFavorite ? Icons.star : Icons.star_outline),
          ),
        ],
      ),
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
                      Text(person.emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        person.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (person.relation != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(person.relation!),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '$age years old',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(countdown),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${details.nextBirthdayWeekday}, ${DateFormat('d MMMM yyyy').format(details.nextBirthdayDate)}',
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Born ${DateFormat('d MMMM yyyy').format(person.birthDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Birthday details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoLine(label: 'Next birthday', value: countdown),
                      _InfoLine(
                        label: 'Weekday',
                        value: details.nextBirthdayWeekday,
                      ),
                      _InfoLine(
                        label: 'Western zodiac',
                        value: ZodiacUtils.fromBirthDate(
                          person.birthDate,
                        ).westernSign,
                      ),
                      if (difference != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Age difference with you',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${difference.years} years, ${difference.months} months, ${difference.days} days',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: 'Edit Person',
                  icon: Icons.edit_outlined,
                  onPressed: () => _edit(context, ref, person),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  label: days == 0
                      ? 'Send Birthday Wish'
                      : 'Prepare a Birthday Wish',
                  icon: Icons.celebration_outlined,
                  onPressed: () => showBirthdayWishComposer(
                    context,
                    person: person,
                    age: turns,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => _shareCard(context, ref, person),
                  icon: const Icon(Icons.card_giftcard_outlined),
                  label: const Text('Share Birthday Card'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () => _shareInfo(context, ref, person, countdown),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share Birthday Info'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () => _delete(context, ref, person),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Person'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    SavedPerson person,
  ) async {
    final updated = await showPersonEditor(context, existing: person);
    if (updated != null) {
      await ref.read(savedBirthdaysProvider.notifier).addOrUpdate(updated);
    }
  }

  Future<void> _shareInfo(
    BuildContext context,
    WidgetRef ref,
    SavedPerson person,
    String countdown,
  ) async {
    final now = DateTime.now();
    final details = AgeCalculationUtils.birthdayDetails(person.birthDate, now);
    final message = details.daysUntilNextBirthday == 0
        ? '${person.name} turns ${person.ageInYears(now)} today 🎂'
        : '$countdown for ${person.name} 🎉';
    await ShareEngine().share(
      context,
      SharePayload(
        text: AppStoreLinks.captionFor(message),
        subject: AppStrings.appName,
      ),
    );
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.birthdayShared,
          parameters: const <String, Object>{'format': 'text'},
        );
  }

  Future<void> _shareCard(
    BuildContext context,
    WidgetRef ref,
    SavedPerson person,
  ) async {
    final result = await BirthdayShareService().shareCard(
      context: context,
      person: person,
    );
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.birthdayCardShared,
          parameters: <String, Object>{
            'format': result == ShareResult.image ? 'image' : 'text_fallback',
          },
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SavedPerson person,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${person.name}?'),
        content: const Text(
          'This removes the person and their birthday reminders.',
        ),
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
      await ref.read(savedBirthdaysProvider.notifier).remove(person.id);
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
