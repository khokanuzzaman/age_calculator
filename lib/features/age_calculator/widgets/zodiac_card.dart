import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../utils/zodiac_utils.dart';

class ZodiacCard extends StatelessWidget {
  const ZodiacCard({super.key, required this.birthDate});

  final DateTime birthDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final info = ZodiacUtils.fromBirthDate(birthDate);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Zodiac & Birth Signs', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              _SignBadge(
                // Variation selector forces colored-emoji presentation so the
                // western glyph matches the Chinese animal emoji style.
                symbol: '${info.westernSymbol}️',
                title: info.westernSign,
                subtitle: '${info.westernElement} · ${info.westernDateRange}',
              ),
              const SizedBox(width: AppSpacing.md),
              _SignBadge(
                symbol: info.chineseEmoji,
                title: '${info.chineseElement} ${info.chineseAnimal}',
                subtitle: 'Chinese zodiac',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              info.westernTraits,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DetailChip(
                  icon: Icons.diamond_outlined,
                  label: 'Birthstone',
                  value: info.birthstone,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DetailChip(
                  icon: Icons.local_florist_outlined,
                  label: 'Birth flower',
                  value: info.birthFlower,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignBadge extends StatelessWidget {
  const _SignBadge({
    required this.symbol,
    required this.title,
    required this.subtitle,
  });

  final String symbol;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.45),
              scheme.surfaceContainerLow.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(symbol, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
