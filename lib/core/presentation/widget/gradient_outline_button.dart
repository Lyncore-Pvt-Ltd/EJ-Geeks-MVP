import 'package:flutter/material.dart';

import '../../theme/app_pallete.dart';

class GradientOutlineButton extends StatelessWidget {
  const GradientOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppPallete.selectionGradient,
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
        borderRadius: BorderRadius.circular(10.5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.5),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: AppPallete.selectionGradient,
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ).createShader(bounds),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppPallete.whiteColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
