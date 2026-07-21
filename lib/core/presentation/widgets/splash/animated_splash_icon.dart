import 'package:flutter/material.dart';

class AnimatedSplashIcon extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  const AnimatedSplashIcon({
    super.key,
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.receipt_long,
            color: Colors.black,
            size: 54,
          ),
        ),
      ),
    );
  }
}
