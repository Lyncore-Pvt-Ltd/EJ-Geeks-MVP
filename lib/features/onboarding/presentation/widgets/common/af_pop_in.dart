import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// Springs its child in from [fromScale] when first built (badges, chips).
class AfPopIn extends StatelessWidget {
  final Widget child;
  final double fromScale;
  final int durationMs;

  const AfPopIn({
    super.key,
    required this.child,
    this.fromScale = 0.4,
    this.durationMs = 300,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: afDuration(context, durationMs),
      curve: AutoFlowTokens.easeSpring,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(
          scale: fromScale + (1 - fromScale) * t,
          child: child,
        ),
      ),
      child: child,
    );
  }
}
