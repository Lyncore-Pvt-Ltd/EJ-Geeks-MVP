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
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressAnimation.value,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),
        );
      },
    );
  }
}
