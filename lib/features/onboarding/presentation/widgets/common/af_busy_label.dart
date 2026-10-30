import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// Cross-fades a button's [idle] label with its [loading] label: 200ms, with
/// a 2px blur and a ±6px vertical shift on whichever side is leaving.
class AfBusyLabel extends StatelessWidget {
  final bool busy;
  final Widget idle;
  final Widget loading;
  final AlignmentGeometry alignment;

  const AfBusyLabel({
    super.key,
    required this.busy,
    required this.idle,
    required this.loading,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: busy ? 1 : 0),
      duration: afDuration(context, 200),
      curve: AutoFlowTokens.easeOut,
      builder: (context, t, _) => Stack(
        alignment: alignment,
        children: [
          _layer(idle, visibility: 1 - t, shiftUp: true),
          _layer(loading, visibility: t, shiftUp: false),
        ],
      ),
    );
  }

  Widget _layer(
    Widget child, {
    required double visibility,
    required bool shiftUp,
  }) {
    final hidden = 1 - visibility;
    return IgnorePointer(
      ignoring: visibility < 0.5,
      child: Opacity(
        opacity: visibility.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (shiftUp ? -6 : 6) * hidden),
          child: hidden > 0.01
              ? ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 2 * hidden,
                    sigmaY: 2 * hidden,
                  ),
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}
