import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedCountText extends StatelessWidget {
  const AnimatedCountText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 0,
    this.formatter,
  });

  final num value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String prefix;
  final String suffix;
  final int decimalPlaces;
  final String Function(num value)? formatter;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (disableAnimations) {
      return Text('$prefix${_format(value)}$suffix', style: style);
    }

    return TweenAnimationBuilder<num>(
      key: ValueKey('$value-$prefix-$suffix-$decimalPlaces'),
      tween: Tween<num>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        return Text('$prefix${_format(animatedValue)}$suffix', style: style);
      },
    );
  }

  String _format(num raw) {
    if (formatter != null) {
      return formatter!(raw);
    }

    if (decimalPlaces > 0) {
      final pattern = '#,##0.${'0' * decimalPlaces}';
      return NumberFormat(pattern).format(raw);
    }

    return NumberFormat('#,##0').format(raw.round());
  }
}
