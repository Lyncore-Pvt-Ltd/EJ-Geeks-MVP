---
name: confirm-destructive-action
description: Pattern for gating a close/discard/delete/regenerate-style action behind a confirmation dialog in this Flutter app, using the shared ConfirmDialog/ShowDeleteDialog widgets via a small reusable per-feature helper function rather than an inline showDialog call.
---

# Confirm before a destructive or hard-to-reverse UI action

Any action in this app that discards unsaved state, deletes data, or
overwrites something already generated/sent (closing a form, deleting an
invoice/line item, regenerating an already-sent PDF, etc.) must go through a
confirmation step before it runs — never wire the triggering `onPressed`
straight to the action.

## Reuse the shared dialog widgets

- `lib/core/presentation/widget/confirm_dialog.dart` (`ConfirmDialog`) — generic
  yes/no prompt. `showDialog<bool>(...)` resolves `true` (confirmed), `false`
  (cancelled), or `null` (dismissed).
- `lib/core/presentation/widget/show_delete_dialog.dart` (`ShowDeleteDialog` /
  `DeleteDialogResult`) — delete-specific variant with an optional "also
  delete files" checkbox.

Both already follow the project's dialog action-button styling (pill-shaped
`Container` + `TextButton`, dark neutral pill for Cancel, colored/gradient
pill for the confirming action) documented in the project's root
`CLAUDE.md` under "Dialog action button styling" — don't hand-roll another
`AlertDialog` with plain `TextButton`s.

## Extract a small reusable helper, don't inline `showDialog`

Wrap the specific confirm copy (title/message/confirm label) for the action
in a small top-level function living next to the widget that uses it, e.g.:

```dart
Future<bool> confirmCloseInvoiceSheet(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const ConfirmDialog(
      title: 'Close Invoice?',
      message: 'Your current progress will be saved and this form will be closed.',
      confirmLabel: 'Close',
    ),
  );
  return confirmed == true;
}
```

Then gate the real action behind it:

```dart
Future<void> _onClosePressed(BuildContext context) async {
  if (!await confirmCloseInvoiceSheet(context)) return;
  // ...proceed with the actual save/close/delete...
}
```

This keeps the confirm copy testable and reusable on its own, instead of
being buried as an anonymous `showDialog` call inside a larger widget's
private method.

## Reference examples in this codebase

- `lib/features/invoice/presentation/widgets/invoice_close_confirm.dart`
  (`confirmCloseInvoiceSheet`) — confirms before the invoice bottom sheet's
  close icon saves and dismisses.
- `_confirmRegeneration` in
  `lib/features/invoice/presentation/widgets/invoice_bottom_sheet.dart` —
  confirms before overwriting an already-generated/sent PDF.
- `ShowDeleteDialog` usage in `invoice_card.dart` and elsewhere — confirms
  before an invoice/line-item delete, with the optional file-deletion
  checkbox.

When adding a new destructive/dismissive action, follow this same shape:
shared dialog widget + a small named helper function + gate the action on
its boolean result.
