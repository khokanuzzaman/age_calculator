import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../utils/life_facts_utils.dart';

class LifeFactsCard extends StatelessWidget {
  const LifeFactsCard({super.key, required this.totalDays});

  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final facts = LifeFactsUtils.fromTotalDays(totalDays);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Life in Numbers', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Fun estimates from the moment you were born',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          for (final fact in facts) ...[
            _FactRow(fact: fact),
            if (fact != facts.last) const Divider(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact});

  final LifeFact fact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(fact.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            fact.label,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          fact.value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
