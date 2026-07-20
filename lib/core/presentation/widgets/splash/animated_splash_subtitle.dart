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
        child: const Text(
          'Invoicing made effortless',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
