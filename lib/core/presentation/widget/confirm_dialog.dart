import 'package:auto_flow/core/presentation/widgets/af/af_primary_button.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_secondary_button.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

import 'dialog_actions.dart';

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
    final tokens = AutoFlowTokens.of(context);

    return AlertDialog(
      title: Semantics(
        header: true,
        child: Text(
          title,
          style: AutoFlowTokens.title.copyWith(color: tokens.ink),
        ),
      ),
      content: Text(
        message,
        style: AutoFlowTokens.body.copyWith(color: tokens.mute2),
      ),
      actionsPadding: kDialogActionsPadding,
      actions: [
        DialogActions(
          children: [
            AfSecondaryButton(
              label: cancelLabel,
              onPressed: () => Navigator.pop(context, false),
            ),
            AfPrimaryButton(
              label: confirmLabel,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ],
    );
  }
}
