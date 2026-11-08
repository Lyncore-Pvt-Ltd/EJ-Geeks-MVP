import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// Pops its child in from [fromScale] when first built (badges, chips).
///
/// Defaults to the overshooting [AutoFlowTokens.easeSpring], which is for
/// onboarding celebration moments only; everyday screens pass
/// `curve: AutoFlowTokens.easeOut`.
class AfPopIn extends StatelessWidget {
  final Widget child;
  final double fromScale;
  final int durationMs;
  final Curve curve;

  const AfPopIn({
    super.key,
    required this.child,
    this.fromScale = 0.4,
    this.durationMs = 300,
    this.curve = AutoFlowTokens.easeSpring,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: afDuration(context, durationMs),
      curve: curve,
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
