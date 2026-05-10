import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'animated_count_text.dart';

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.label,
    this.height = 6,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
  });

  final double value;
  final String? label;
  final double height;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = value.clamp(0, 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Expanded(child: Text(label!)),
              AnimatedCountText(
                value: normalized * 100,
                decimalPlaces: 0,
                suffix: '%',
                style: Theme.of(context).textTheme.titleSmall,
                duration: duration,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: TweenAnimationBuilder<double>(
            key: ValueKey(normalized),
            tween: Tween<double>(begin: 0, end: normalized),
            duration: duration,
            curve: curve,
            builder: (context, animated, _) {
              return LinearProgressIndicator(
                value: animated,
                minHeight: height,
                backgroundColor: scheme.surfaceContainerHighest,
              );
            },
          ),
        ),
      ],
    );
  }
}
