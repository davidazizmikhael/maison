import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ambient (looping) motion switch. The integration walkthrough turns this
/// off: endless animations never settle, so `pumpAndSettle` would time out.
class MaisonMotion {
  static bool ambient = true;
}

/// Gentle vertical float, borrowed from the "Walk the House" direction:
/// the card drifts up and back on a slow sine, staggered by [phase].
class FloatingCard extends StatefulWidget {
  const FloatingCard({
    super.key,
    required this.child,
    this.amplitude = 4,
    this.duration = const Duration(milliseconds: 4000),
    this.phase = 0,
  });

  final Widget child;
  final double amplitude;
  final Duration duration;
  final double phase; // 0..1 offset into the cycle

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (MaisonMotion.ambient) {
      _controller = AnimationController(vsync: this, duration: widget.duration)
        ..value = widget.phase
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -widget.amplitude * math.sin(controller.value * 2 * math.pi)),
        child: child,
      ),
      child: widget.child,
    );
  }
}
