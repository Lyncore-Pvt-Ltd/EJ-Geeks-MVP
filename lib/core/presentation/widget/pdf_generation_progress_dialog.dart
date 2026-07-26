import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

/// Non-dismissible loading dialog shown while PDF(s) are being generated.
/// Shared by both the Invoice and Inspection tabs' "Generate" actions.
class PdfGenerationProgressDialog extends StatelessWidget {
  const PdfGenerationProgressDialog({
    super.key,
    this.message = 'Generating PDF…',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: ShaderMask(
                  shaderCallback: (bounds) => SweepGradient(
                    colors: [
                      ...AppPallete.selectionGradient,
                      AppPallete.selectionGradient[0],
                    ],
                  ).createShader(bounds),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
