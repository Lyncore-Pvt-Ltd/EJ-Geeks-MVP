import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
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
      child: AfPressable(
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: tokens.line),
          ),
          child: Icon(icon, size: 20, color: tokens.ink),
        ),
      ),
    );
  }
}
