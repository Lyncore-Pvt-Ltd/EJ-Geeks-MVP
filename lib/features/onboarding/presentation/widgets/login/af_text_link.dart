import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/af/af_motion.dart';
import '../../../../../core/theme/autoflow_tokens.dart';

/// Underlined 13px link with a 44px-tall tap target.
class AfTextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final FontWeight fontWeight;

  const AfTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? AutoFlowTokens.of(context).ink;
    return Semantics(
      link: true,
      child: AfPressable(
        onTap: onTap,
        pressedScale: 0.96,
        focusRadius: AfRadius.smallAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Align(
            widthFactor: 1,
            child: Text(
              label,
              style: AutoFlowTokens.caption.copyWith(
                color: resolved,
                fontWeight: fontWeight,
                decoration: TextDecoration.underline,
                decorationColor: resolved,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
