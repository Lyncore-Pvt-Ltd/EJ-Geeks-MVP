import 'package:ej_geek/core/presentation/widget/confirm_dialog.dart';
import 'package:flutter/material.dart';

/// Shows a [ConfirmDialog] asking the user to confirm closing the invoice
/// bottom sheet. Returns `true` only if the user tapped the confirm action;
/// `false` for cancel or dismissal, so callers can safely gate the existing
/// save-then-close flow behind it.
Future<bool> confirmCloseInvoiceSheet(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const ConfirmDialog(
      title: 'Close Invoice?',
      message:
          'Detected some values in field. Do you want to save your '
          'progress?',
      confirmLabel: 'Save',
    ),
  );
  return confirmed == true;
}
