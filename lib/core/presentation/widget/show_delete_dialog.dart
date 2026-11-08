import 'package:auto_flow/core/presentation/widgets/af/af_secondary_button.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

import 'dialog_actions.dart';

class DeleteDialogResult {
  final bool confirmed;
  final bool deleteFiles;

  const DeleteDialogResult({required this.confirmed, this.deleteFiles = false});
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
    final tokens = AutoFlowTokens.of(context);

    return AlertDialog(
      title: Semantics(
        header: true,
        child: Text(
          widget.title,
          style: AutoFlowTokens.title.copyWith(color: tokens.ink),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: AutoFlowTokens.body.copyWith(color: tokens.mute2),
          ),
          if (widget.showDeleteFilesOption)
            CheckboxListTile(
              value: _deleteFiles,
              onChanged: (value) =>
                  setState(() => _deleteFiles = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Also delete images & PDF files',
                style: AutoFlowTokens.body.copyWith(color: tokens.ink),
              ),
            ),
        ],
      ),
      actionsPadding: kDialogActionsPadding,
      actions: [
        DialogActions(
          children: [
            AfSecondaryButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(
                context,
                const DeleteDialogResult(confirmed: false),
              ),
            ),
            DestructiveButton(
              label: 'Delete',
              icon: Icons.delete_outline,
              onPressed: () => Navigator.pop(
                context,
                DeleteDialogResult(confirmed: true, deleteFiles: _deleteFiles),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
