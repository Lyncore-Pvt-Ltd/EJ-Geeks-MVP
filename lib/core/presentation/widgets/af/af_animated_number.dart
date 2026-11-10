import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// Numeric text that counts to [value] instead of snapping (stats, totals).
///
/// The first build counts up from 0; later [value] changes tween from the
/// number currently on screen. Reduced motion shows the final value at once
/// via [afDuration]. Screen readers always hear the final formatted value,
/// never an in-flight one; [semanticsPrefix] puts a title in front
/// (`"Total Revenue: A$1200"`).
class AfAnimatedNumber extends StatelessWidget {
  final double value;
  final String Function(double value) formatter;
  final TextStyle style;
  final int durationMs;
  final String? semanticsPrefix;

  const AfAnimatedNumber({
    super.key,
    required this.value,
    required this.formatter,
    required this.style,
    this.durationMs = 500,
    this.semanticsPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final finalText = formatter(value);
    final label = semanticsPrefix == null
        ? finalText
        : '$semanticsPrefix: $finalText';

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: afDuration(context, durationMs),
        curve: AutoFlowTokens.easeOut,
        builder: (context, v, _) =>
            Text(formatter(v), maxLines: 1, style: style),
      ),
    );
  }
}
