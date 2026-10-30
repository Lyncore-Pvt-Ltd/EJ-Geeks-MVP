import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../common/af_motion.dart';

/// 72px orange tick that springs in, draws its check and bursts 8 sparks,
/// over a breathing glow.
class SuccessTick extends StatefulWidget {
  const SuccessTick({super.key});

  @override
  State<SuccessTick> createState() => _SuccessTickState();
}

class _SuccessTickState extends State<SuccessTick>
    with SingleTickerProviderStateMixin {
  static const _size = 72.0;
  static const _sparkCount = 8;
  // Last spark starts at 200 + 7*30 = 410ms and runs 900ms.
  static const _totalMs = 1310;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalMs),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else if (_controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phase(int startMs, int durationMs, Curve curve) {
    final ms = _controller.value * _totalMs;
    final t = ((ms - startMs) / durationMs).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pop = _phase(0, 500, AutoFlowTokens.easeSpring);
          final draw = _phase(250, 400, AutoFlowTokens.easeOut);
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const OverflowBox(
                maxWidth: _size + 48,
                maxHeight: _size + 48,
                child: AfGlow(
                  width: _size + 48,
                  height: _size + 48,
                  blur: 32,
                  opacity: 0.6,
                  period: Duration(seconds: 3),
                ),
              ),
              for (var i = 0; i < _sparkCount; i++) _spark(i),
              Opacity(
                opacity: pop.clamp(0, 1),
                child: Transform.scale(
                  scale: lerpDouble(0.85, 1, pop),
                  child: Container(
                    width: _size,
                    height: _size,
                    decoration: const BoxDecoration(
                      color: AutoFlowTokens.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xB3FCA311),
                          offset: Offset(0, 16),
                          blurRadius: 32,
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: CustomPaint(painter: _CheckPainter(progress: draw)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _spark(int i) {
    final angle = i / _sparkCount * math.pi * 2;
    final radius = 56.0 + (i % 2) * 16;
    final t = _phase(200 + i * 30, 900, AutoFlowTokens.easeOut);
    final opacity = t < 0.3 ? t / 0.3 : 1 - (t - 0.3) / 0.7;
    return Transform.translate(
      offset: Offset(
        math.cos(angle) * radius * t,
        math.sin(angle) * radius * t,
      ),
      child: Opacity(
        opacity: t == 0 ? 0 : opacity.clamp(0, 1),
        child: Transform.scale(
          scale: lerpDouble(0.4, 1, t),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: i.isOdd ? const Color(0xFFE5E5E5) : AutoFlowTokens.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;

  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    // 32px icon centred in the circle, drawn on the design's 24-unit grid.
    const iconSize = 32.0;
    final scale = iconSize / 24;
    canvas.translate((size.width - iconSize) / 2, (size.height - iconSize) / 2);
    canvas.scale(scale);
    final path = Path()
      ..moveTo(20, 6)
      ..lineTo(9, 17)
      ..lineTo(4, 12);
    final paint = Paint()
      ..color = AutoFlowTokens.onAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
