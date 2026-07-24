import 'package:flutter/material.dart';

import '../../theme/app_pallete.dart';

class ShowDeleteDialog extends StatelessWidget {
  final String title;
  final String message;

  const ShowDeleteDialog({
    super.key,
    this.title = 'Delete Item',
    this.message = 'Are you sure you want to delete this item ?',
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Cancel', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),

        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red[500],
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Delete', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 5),
                const Icon(Icons.delete, size: 16, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
