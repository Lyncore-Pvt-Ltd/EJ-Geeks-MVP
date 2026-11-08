import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

class SplashProgressBar extends StatelessWidget {
  final Animation<double> progressAnimation;

  const SplashProgressBar({super.key, required this.progressAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progressAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: AfRadius.chipAll,
          child: LinearProgressIndicator(
            value: progressAnimation.value,
            backgroundColor: AutoFlowTokens.dark.line,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AutoFlowTokens.accent,
            ),
            minHeight: 4,
          ),
        );
      },
    );
  }
}
