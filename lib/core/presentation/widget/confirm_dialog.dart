import 'package:auto_flow/core/presentation/widgets/af/af_primary_button.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_secondary_button.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

import 'dialog_actions.dart';

/// Generic yes/no confirmation prompt. Prefer [showConfirmDialog]; it resolves
/// to `true` when confirmed, `false` when cancelled/dismissed. Set
/// [destructive] for actions like Log out / Delete (red confirm button).
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final IconData? confirmIcon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Yes',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.confirmIcon,
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
            if (destructive)
              DestructiveButton(
                label: confirmLabel,
                icon: confirmIcon,
                onPressed: () => Navigator.pop(context, true),
              )
            else
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

/// Shows a [ConfirmDialog] and returns whether the user confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Yes',
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData? confirmIcon,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      confirmIcon: confirmIcon,
    ),
  );
  return confirmed == true;
}
