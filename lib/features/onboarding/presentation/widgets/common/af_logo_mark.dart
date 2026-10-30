import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// Navy rounded "af" tile, optionally with a breathing orange glow behind.
class AfLogoMark extends StatelessWidget {
  final double size;
  final bool glow;

  const AfLogoMark({super.key, this.size = 28, this.glow = false});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final large = size >= 48;
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.navy,
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        boxShadow: large ? AutoFlowTokens.heroShadow : null,
      ),
      child: Text(
        'af',
        style: TextStyle(
          fontFamily: AutoFlowTokens.fontFamily,
          fontSize: large ? 17 : 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.04 * (large ? 17 : 13),
          color: Colors.white,
        ),
      ),
    );
    if (!glow) return tile;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          OverflowBox(
            maxWidth: size + 32,
            maxHeight: size + 32,
            child: AfGlow(
              width: size + 32,
              height: size + 32,
              blur: 24,
              opacity: 0.35,
            ),
          ),
          tile,
        ],
      ),
    );
  }
}

/// Header lockup: small mark + "AutoFlow" wordmark.
class AfWordmark extends StatelessWidget {
  const AfWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AfLogoMark(),
        const SizedBox(width: 8),
        Text(
          'AutoFlow',
          style: AutoFlowTokens.title.copyWith(
            color: tokens.ink,
            letterSpacing: -0.51,
          ),
        ),
      ],
    );
  }
}
