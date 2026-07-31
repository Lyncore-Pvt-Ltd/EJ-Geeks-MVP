// TEMPORARY TRIAL LOCK — remove when no longer needed
import 'package:flutter/material.dart';

import '../../theme/app_pallete.dart';

/// Shown once the trial period has expired. Informational only —
/// resolves via `showDialog(context: context, builder: (_) => const TrialExpiredDialog())`.
class TrialExpiredDialog extends StatelessWidget {
  const TrialExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        'Trial Expired',
        style: TextStyle(
          color: isDark ? AppPallete.cascadingWhite : AppPallete.tricornBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        'Your 2-day trial period has ended. Please contact Lyncore Pvt. Ltd. '
        'to unlock the app.',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppPallete.selectionGradient,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
