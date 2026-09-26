import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../models/saved_person.dart';
import '../providers/saved_birthdays_provider.dart';
import '../utils/saved_people_utils.dart';
import '../widgets/person_editor_sheet.dart';
import 'person_detail_screen.dart';

class SavedBirthdaysScreen extends ConsumerStatefulWidget {
  const SavedBirthdaysScreen({super.key});

  @override
  ConsumerState<SavedBirthdaysScreen> createState() =>
      _SavedBirthdaysScreenState();
}

class _SavedBirthdaysScreenState extends ConsumerState<SavedBirthdaysScreen> {
  late final TextEditingController _searchController;
  SavedPeopleFilter _filter = SavedPeopleFilter.upcoming;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(AnalyticsEvent.myPeopleOpened);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final people = ref.watch(savedBirthdaysProvider);
    final visiblePeople = SavedPeopleUtils.filter(
      people,
      filter: _filter,
      query: _searchController.text,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My People'),
        actions: [
          IconButton(
            tooltip: 'Add person',
            onPressed: () => _add(context),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      floatingActionButton: people.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add),
              label: const Text('Add person'),
            )
          : null,
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: people.isEmpty
                ? const _EmptyState()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.base,
                          AppSpacing.base,
                          AppSpacing.base,
                          AppSpacing.sm,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Search people',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              tooltip: 'Clear search',
                              onPressed: _searchController.text.isEmpty
                                  ? null
                                  : () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ),
                      ),
                      _FilterChips(
                        selected: _filter,
                        onSelected: (filter) {
                          setState(() => _filter = filter);
                          ref
                              .read(appAnalyticsProvider)
                              .logEventSafely(
                                AnalyticsEvent.myPeopleFilterChanged,
                                parameters: <String, Object>{
                                  'filter': filter.name,
                                },
                              );
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: visiblePeople.isEmpty
                            ? _FilteredEmptyState(filter: _filter)
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.base,
                                  0,
                                  AppSpacing.base,
                                  AppSpacing.huge * 2,
                                ),
                                itemCount: visiblePeople.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final person = visiblePeople[index];
                                  return _PersonCard(
                                    person: person,
                                    onTap: () => _openDetail(context, person),
                                    onFavorite: () => ref
                                        .read(savedBirthdaysProvider.notifier)
                                        .toggleFavorite(person.id),
                                    onDelete: () => _delete(person),
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

  Future<void> _add(BuildContext context) async {
    final person = await showPersonEditor(context);
    if (person != null) {
      await ref.read(savedBirthdaysProvider.notifier).addOrUpdate(person);
    }
  }

  void _openDetail(BuildContext context, SavedPerson person) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PersonDetailScreen(personId: person.id),
      ),
    );
  }

  Future<void> _delete(SavedPerson person) async {
    await HapticFeedback.selectionClick();
    if (!mounted) {
      return;
    }
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
    if (confirmed != true) {
      return;
    }
    await ref.read(savedBirthdaysProvider.notifier).remove(person.id);
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Removed ${person.name}')));
    }
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final SavedPeopleFilter selected;
  final ValueChanged<SavedPeopleFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = {
      SavedPeopleFilter.upcoming: 'Upcoming',
      SavedPeopleFilter.thisMonth: 'This Month',
      SavedPeopleFilter.favorites: 'Favorites',
      SavedPeopleFilter.all: 'All',
    };
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = SavedPeopleFilter.values[index];
          return FilterChip(
            label: Text(labels[filter]!),
            selected: filter == selected,
            onSelected: (_) => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.person,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  final SavedPerson person;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final details = AgeCalculationUtils.birthdayDetails(person.birthDate, now);
    final age = person.ageInYears(now);
    final daysLeft = details.daysUntilNextBirthday;
    final turning = age + (daysLeft == 0 ? 0 : 1);
    final countdown = daysLeft == 0
        ? 'Birthday is today!'
        : 'Turns $turning in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Hero(
            tag: 'person-avatar:${person.id}',
            child: Material(
              color: Colors.transparent,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primaryContainer,
                child: Text(person.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
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
                if (person.relation != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    person.relation!,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  countdown,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM').format(details.nextBirthdayDate),
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
                tooltip: person.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: onFavorite,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Icon(
                    person.isFavorite ? Icons.star : Icons.star_outline,
                    key: ValueKey<bool>(person.isFavorite),
                  ),
                ),
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: scheme.primary),
            const SizedBox(height: AppSpacing.base),
            Text(
              'No people yet',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add the people who matter to you and never miss their birthday.',
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

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.filter});

  final SavedPeopleFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      SavedPeopleFilter.favorites => 'No favorites yet.',
      SavedPeopleFilter.thisMonth => 'No birthdays this month.',
      _ => 'No people found.',
    };
    return Center(child: Text(message));
  }
}
