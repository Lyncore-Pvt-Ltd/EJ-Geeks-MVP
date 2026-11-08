import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// 44×44 bordered icon button (e.g. Back).
class AfIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  const AfIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: AfPressable.builder(
        onTap: onPressed,
        builder: (context, pressed) => AnimatedContainer(
          duration: afDuration(context, 160),
          curve: AutoFlowTokens.easeOut,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            // Press fills with the line colour.
            color: pressed ? tokens.line : tokens.card,
            borderRadius: AfRadius.controlAll,
            border: Border.all(color: tokens.line),
          ),
          child: Icon(icon, size: 20, color: tokens.ink),
        ),
      ),
    );
  }
}
