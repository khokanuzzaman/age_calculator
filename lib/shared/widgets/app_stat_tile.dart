import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class AppStatTile extends StatelessWidget {
  const AppStatTile({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.icon,
  }) : assert(
         value != null || valueWidget != null,
         'Either value or valueWidget must be provided.',
       );

  final String label;
  final String? value;
  final Widget? valueWidget;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppDurations.slow,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        final slide = Tween<double>(begin: 12, end: 0).transform(progress);
        final scale = Tween<double>(begin: 0.96, end: 1).transform(progress);

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, slide),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            valueWidget ??
                Text(
                  value!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
