import 'package:flutter/material.dart';

class SplashDotsIndicator extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const SplashDotsIndicator({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDot(true),
          const SizedBox(width: 12),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          _buildDot(false),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
