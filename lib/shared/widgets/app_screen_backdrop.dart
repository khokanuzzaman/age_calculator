import 'package:flutter/material.dart';

class AppScreenBackdrop extends StatelessWidget {
  const AppScreenBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.surface,
              scheme.surfaceContainerLowest,
              scheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -90,
              child: _GlowOrb(
                color: scheme.primary.withValues(alpha: 0.16),
                size: 290,
              ),
            ),
            Positioned(
              top: 140,
              right: -100,
              child: _GlowOrb(
                color: scheme.tertiary.withValues(alpha: 0.12),
                size: 240,
              ),
            ),
            Positioned(
              bottom: -130,
              left: -80,
              child: _GlowOrb(
                color: scheme.secondary.withValues(alpha: 0.1),
                size: 260,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.05, 1],
        ),
      ),
    );
  }
}
