import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// Transparent 48px-wide icon toggle that sits inside a field (e.g. the
/// password eye). Press scales to 0.9 and turns the icon from mute to ink.
class AfInlineIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double size;

  /// Idle icon colour (defaults to mute). Pressed always turns ink.
  final Color? color;

  const AfInlineIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: AfPressable.builder(
        onTap: onPressed,
        pressedScale: 0.9,
        builder: (context, pressed) => SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end: pressed ? tokens.ink : (color ?? tokens.mute),
              ),
              duration: afDuration(context, 160),
              curve: AutoFlowTokens.easeOut,
              builder: (context, color, _) =>
                  Icon(icon, size: size, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
