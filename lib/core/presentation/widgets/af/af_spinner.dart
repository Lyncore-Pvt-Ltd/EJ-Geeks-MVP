import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ring spinner: a [track] circle with one [color] quarter rotating on top.
/// Keeps spinning under reduced motion, as in the design.
class AfSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final Color track;
  final Duration period;

  const AfSpinner({
    super.key,
    required this.size,
    required this.color,
    required this.track,
    this.strokeWidth = 2,
    this.period = const Duration(milliseconds: 600),
  });

  @override
  State<AfSpinner> createState() => _AfSpinnerState();
}

class _AfSpinnerState extends State<AfSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _SpinnerPainter(
          color: widget.color,
          track: widget.track,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final Color track;
  final double strokeWidth;

  _SpinnerPainter({
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawOval(inset, paint..color = track);
    canvas.drawArc(
      inset,
      -math.pi * 3 / 4,
      math.pi / 2,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      oldDelegate.strokeWidth != strokeWidth;
}
