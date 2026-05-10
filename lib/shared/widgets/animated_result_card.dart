import 'package:flutter/material.dart';

class AnimatedResultCard extends StatefulWidget {
  const AnimatedResultCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0, 0.05),
    this.animate = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;
  final bool animate;

  @override
  State<AnimatedResultCard> createState() => _AnimatedResultCardState();
}

class _AnimatedResultCardState extends State<AnimatedResultCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      _visible = true;
      return;
    }

    Future<void>.delayed(widget.delay, () {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldAnimate = widget.animate && !disableAnimations;

    if (!shouldAnimate) {
      return widget.child;
    }

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: widget.curve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : widget.beginOffset,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
