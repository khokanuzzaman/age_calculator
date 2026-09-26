import 'dart:async';

import 'package:flutter/material.dart';

/// A lightweight, reusable entrance for screen sections.
class AppEntrance extends StatefulWidget {
  const AppEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 380),
    this.animate = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final bool animate;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      _visible = true;
      return;
    }
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AppEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate) {
      _timer?.cancel();
      _visible = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!widget.animate || reducedMotion) {
      return widget.child;
    }

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.025),
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _visible ? 1 : 0.985,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
