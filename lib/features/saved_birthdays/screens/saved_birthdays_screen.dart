import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../models/saved_person.dart';
import '../providers/saved_birthdays_provider.dart';
import '../widgets/person_editor_sheet.dart';

class SavedBirthdaysScreen extends ConsumerWidget {
  const SavedBirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(savedBirthdaysProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Saved Birthdays')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: people.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.huge * 2,
                    ),
                    itemCount: people.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final person = people[index];
                      return _PersonCard(
                        person: person,
                        onEdit: () => _edit(context, ref, person),
                        onDelete: () => _delete(context, ref, person),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final person = await showPersonEditor(context);
    if (person != null) {
      await ref.read(savedBirthdaysProvider.notifier).addOrUpdate(person);
    }
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

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SavedPerson person,
  ) async {
    await HapticFeedback.selectionClick();
    await ref.read(savedBirthdaysProvider.notifier).remove(person.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Removed ${person.name}')));
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.person,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedPerson person;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final details = AgeCalculationUtils.birthdayDetails(person.birthDate, now);
    final age = person.ageInYears(now);
    final daysLeft = details.daysUntilNextBirthday;
    final turning = age + 1;

    final countdown = daysLeft == 0
        ? '🎉 Birthday is today!'
        : 'Turns $turning in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}';

    return AppCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.primaryContainer,
            child: Text(person.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$age years old · ${DateFormat('d MMM yyyy').format(person.birthDate)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  countdown,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: scheme.onSurfaceVariant),
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cake_outlined, size: 64, color: scheme.primary),
            const SizedBox(height: AppSpacing.base),
            Text(
              'No saved birthdays yet',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add family, friends, or pets to track their age and never miss a birthday.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
