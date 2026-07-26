import 'package:flutter/material.dart';

import '../../theme/app_pallete.dart';

class DeleteDialogResult {
  final bool confirmed;
  final bool deleteFiles;

  const DeleteDialogResult({
    required this.confirmed,
    this.deleteFiles = false,
  });
}

class ShowDeleteDialog extends StatefulWidget {
  final String title;
  final String message;

  /// When true, shows a checkbox letting the user opt into also deleting
  /// this item's related on-disk files (images/PDFs). Off by default and
  /// unused by callers that don't have files to worry about (e.g. deleting
  /// a single line item).
  final bool showDeleteFilesOption;

  const ShowDeleteDialog({
    super.key,
    this.title = 'Delete Item',
    this.message = 'Are you sure you want to delete this item ?',
    this.showDeleteFilesOption = false,
  });

  @override
  State<ShowDeleteDialog> createState() => _ShowDeleteDialogState();
}

class _ShowDeleteDialogState extends State<ShowDeleteDialog> {
  bool _deleteFiles = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkPillColor = isDark
        ? AppPallete.dynamicBlack
        : AppPallete.tricornBlack;

    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(
          color: isDark ? AppPallete.cascadingWhite : AppPallete.tricornBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message, style: const TextStyle(fontSize: 16)),
          if (widget.showDeleteFilesOption)
            CheckboxListTile(
              value: _deleteFiles,
              onChanged: (value) =>
                  setState(() => _deleteFiles = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Also delete images & PDF files',
                style: TextStyle(fontSize: 14),
              ),
            ),
        ],
      ),
      actions: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: darkPillColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(
              context,
              const DeleteDialogResult(confirmed: false),
            ),
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
            onPressed: () => Navigator.pop(
              context,
              DeleteDialogResult(confirmed: true, deleteFiles: _deleteFiles),
            ),
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
