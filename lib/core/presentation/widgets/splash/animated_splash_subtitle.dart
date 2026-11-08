import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

class AnimatedSplashSubtitle extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const AnimatedSplashSubtitle({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Text(
          'Invoicing made effortless',
          textAlign: TextAlign.center,
          style: AutoFlowTokens.body.copyWith(color: AutoFlowTokens.dark.mute2),
        ),
      ),
    );
  }
}
