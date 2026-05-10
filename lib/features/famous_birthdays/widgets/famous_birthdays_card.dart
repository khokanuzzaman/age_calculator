import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../model/famous_birthday_model.dart';
import '../provider/famous_birthday_provider.dart';

class FamousBirthdaysCard extends ConsumerStatefulWidget {
  const FamousBirthdaysCard({super.key, required this.monthDay});

  final String monthDay;

  @override
  ConsumerState<FamousBirthdaysCard> createState() =>
      _FamousBirthdaysCardState();
}

class _FamousBirthdaysCardState extends ConsumerState<FamousBirthdaysCard> {
  BirthdayRegionFilter _filter = BirthdayRegionFilter.all;

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(famousBirthdaysProvider(widget.monthDay));
    final locale = ref.watch(appLocaleProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final showRegionalFilter = !locale.isEnglish || locale.hasCuratedData;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.groups_2_outlined, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Born on This Day', style: textTheme.titleLarge),
                    Text(
                      'Famous people who share your birthday',
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
                    .read(famousBirthdaysProvider(widget.monthDay).notifier)
                    .refresh(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (showRegionalFilter) ...[
            const SizedBox(height: AppSpacing.base),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == BirthdayRegionFilter.all,
                  onTap: () =>
                      setState(() => _filter = BirthdayRegionFilter.all),
                ),
                _FilterChip(
                  label: locale.regionLabel,
                  selected: _filter == BirthdayRegionFilter.regional,
                  onTap: () =>
                      setState(() => _filter = BirthdayRegionFilter.regional),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.base),
          asyncItems.when(
            data: (items) {
              final filtered = _applyFilter(
                items,
                locale.languageCode,
              ).take(10).toList(growable: false);
              if (filtered.isEmpty) {
                return const _InfoMessage(
                  icon: Icons.info_outline,
                  text: 'No data found for this date.',
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    _PersonTile(
                      item: filtered[i],
                      regionLabel: locale.regionLabel,
                      isRegional: filtered[i].isRegional(locale.languageCode),
                    ),
                    if (i != filtered.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
            error: (_, _) => const _InfoMessage(
              icon: Icons.wifi_off_outlined,
              text: 'Famous birthday information is not available right now.',
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: _InfoMessage(
                icon: Icons.hourglass_top_rounded,
                text: 'Loading famous birthdays...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FamousBirthday> _applyFilter(
    List<FamousBirthday> items,
    String languageCode,
  ) {
    switch (_filter) {
      case BirthdayRegionFilter.all:
        return items;
      case BirthdayRegionFilter.regional:
        return items
            .where((e) => e.isRegional(languageCode))
            .toList(growable: false);
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: scheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.item,
    required this.regionLabel,
    required this.isRegional,
  });

  final FamousBirthday item;
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
            CircleAvatar(
              radius: 22,
              backgroundColor: scheme.primaryContainer,
              foregroundImage:
                  (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty)
                  ? NetworkImage(item.thumbnailUrl!)
                  : null,
              child: (item.thumbnailUrl == null || item.thumbnailUrl!.isEmpty)
                  ? Icon(Icons.person, color: scheme.onPrimaryContainer)
                  : null,
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
                    item.birthYear != null
                        ? '${item.name} (${item.birthYear})'
                        : item.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (item.pageUrl != null && item.pageUrl!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: () => _openLink(context, item.pageUrl!),
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

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (ok || !context.mounted) {
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

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.icon, required this.text});

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
