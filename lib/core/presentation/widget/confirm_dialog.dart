import 'package:flutter/material.dart';

import '../../theme/app_pallete.dart';

/// Generic yes/no confirmation prompt. Shown via
/// `showDialog<bool>(context: context, builder: (_) => ConfirmDialog(...))` —
/// resolves to `true` when confirmed, `false` when cancelled/dismissed.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Yes',
    this.cancelLabel = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkPillColor = isDark
        ? AppPallete.dynamicBlack
        : AppPallete.tricornBlack;

    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppPallete.cascadingWhite : AppPallete.tricornBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: darkPillColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppPallete.selectionGradient,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
