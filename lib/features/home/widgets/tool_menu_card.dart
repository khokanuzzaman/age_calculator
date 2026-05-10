import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';

class ToolMenuCard extends StatelessWidget {
  const ToolMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.accent,
    this.featured = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  /// Optional per-tool accent. Falls back to the theme primary when null.
  final Color? accent;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return featured ? _buildFeatured(context) : _buildGridTile(context);
  }

  Widget _buildFeatured(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tint = accent ?? scheme.primary;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Row(
        children: [
          _IconChip(icon: icon, tint: tint, size: 30, padding: AppSpacing.base),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right, size: 22, color: tint),
        ],
      ),
    );
  }

  Widget _buildGridTile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tint = accent ?? scheme.primary;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconChip(icon: icon, tint: tint, size: 20, padding: AppSpacing.sm),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.tint,
    required this.size,
    required this.padding,
  });

  final IconData icon;
  final Color tint;
  final double size;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(icon, size: size, color: tint),
      ),
    );
  }
}
