import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.onTap,
    this.emphasized = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final gradient = emphasized
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerLow,
              scheme.primaryContainer.withValues(alpha: 0.18),
            ],
          )
        : null;

    return Material(
      color: emphasized ? Colors.transparent : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          border: Border.all(
            color: scheme.outlineVariant.withValues(
              alpha: emphasized ? 0.42 : 0.30,
            ),
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
