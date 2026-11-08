import 'package:auto_flow/core/presentation/widget/confirm_dialog.dart';
import 'package:auto_flow/core/presentation/widget/show_delete_dialog.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_status_chip.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/invoice/data/constants/invoice_date_format.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_summary.dart';
import 'package:auto_flow/features/invoice/domain/entities/payment_status.dart';
import 'package:auto_flow/features/invoice/domain/entities/service_status.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_bottom_sheet.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.summary});

  final InvoiceSummary summary;

  Future<void> _openInvoice(BuildContext context) async {
    final invoiceBloc = context.read<InvoiceBloc>();
    await InvoiceBottomSheet.show(
      context,
      invoiceId: summary.id,
      createdAt: summary.createdAt,
    );
    invoiceBloc.add(const InvoiceListRequested());
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final invoiceBloc = context.read<InvoiceBloc>();
    final result = await showDialog<DeleteDialogResult>(
      context: context,
      builder: (_) => ShowDeleteDialog(
        title: 'Delete Invoice',
        message: 'Are you sure you want to delete this invoice?',
        showDeleteFilesOption: true,
      ),
    );
    if (result?.confirmed == true) {
      invoiceBloc.add(
        InvoiceDeleted(summary.id, deleteFiles: result!.deleteFiles),
      );
    }
  }

  Future<void> _confirmMarkPaid(BuildContext context) async {
    final invoiceBloc = context.read<InvoiceBloc>();
    final isPaid = summary.paymentStatus == PaymentStatus.paid;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: isPaid ? 'Undo Payment' : 'Mark as Paid',
        message: isPaid
            ? 'Are you sure you want to undo the paid status for this invoice?'
            : 'Confirm this invoice has been paid? A paid date and time will be recorded.',
      ),
    );
    if (confirmed == true) {
      invoiceBloc.add(
        isPaid
            ? InvoicePaymentMarkedUnpaid(summary.id)
            : InvoicePaymentMarkedPaid(summary.id),
      );
    }
  }

  Future<void> _generatePdf(BuildContext context) async {
    final invoiceBloc = context.read<InvoiceBloc>();
    await InvoiceBottomSheet.show(
      context,
      invoiceId: summary.id,
      createdAt: summary.createdAt,
      autoGenerate: true,
    );
    invoiceBloc.add(const InvoiceListRequested());
  }

  void _showActionSheet(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final isCompleted = summary.serviceStatus == ServiceStatus.completed;
    final isPaid = summary.paymentStatus == PaymentStatus.paid;
    final vehicleLine = [
      summary.make,
      summary.model,
      summary.rego,
      summary.year,
    ].where((part) => part.isNotEmpty).join(' · ');
    final sheetTitle = summary.ownerName.isEmpty
        ? (vehicleLine.isEmpty
              ? 'Invoice #${summary.id.substring(0, 8)}'
              : vehicleLine)
        : summary.ownerName;

    Widget rule() => Divider(color: tokens.line, height: 1, thickness: 1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AfSpace.gutter,
            0,
            AfSpace.gutter,
            AfSpace.l24,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: AfRadius.cardAll,
            border: Border.all(color: tokens.line),
            boxShadow: AutoFlowTokens.cardShadow,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: AfSpace.s12,
                    bottom: AfSpace.s8,
                  ),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.line,
                    borderRadius: AfRadius.chipAll,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AfSpace.l24,
                    AfSpace.xs4,
                    AfSpace.l24,
                    AfSpace.s12,
                  ),
                  child: Text(
                    sheetTitle,
                    style: AutoFlowTokens.title.copyWith(color: tokens.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                rule(),
                _ActionRow(
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openInvoice(context);
                  },
                ),
                rule(),
                _ActionRow(
                  icon: isCompleted ? Icons.undo : Icons.check_circle_outline,
                  label: isCompleted
                      ? 'Undo Complete Service'
                      : 'Complete Service',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<InvoiceBloc>().add(
                      isCompleted
                          ? InvoiceServiceReverted(summary.id)
                          : InvoiceServiceCompleted(summary.id),
                    );
                  },
                ),
                rule(),
                _ActionRow(
                  icon: isPaid ? Icons.undo : Icons.attach_money,
                  label: isPaid ? 'Undo Payment' : 'Mark Paid',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmMarkPaid(context);
                  },
                ),
                rule(),
                _ActionRow(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Generate PDF',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _generatePdf(context);
                  },
                ),
                rule(),
                _ActionRow(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: AutoFlowTokens.errorFg,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDelete(context);
                  },
                ),
                const SizedBox(height: AfSpace.s8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final metaStyle = AutoFlowTokens.caption.copyWith(color: tokens.mute);
    final phoneNumber = summary.phoneNumber.isNotEmpty
        ? '+61 ${summary.phoneNumber}'
        : '';
    final vehicleLine = [
      summary.make,
      summary.model,
      summary.rego,
      summary.year,
    ].where((part) => part.isNotEmpty).join(' · ');
    final isCompleted = summary.serviceStatus == ServiceStatus.completed;
    final isPaid = summary.paymentStatus == PaymentStatus.paid;

    return Slidable(
      key: ValueKey(summary.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (context) => _showActionSheet(context),
            backgroundColor: tokens.soft,
            foregroundColor: tokens.ink,
            icon: Icons.more_horiz,
            label: 'More',
          ),
          SlidableAction(
            onPressed: (context) => _confirmDelete(context),
            backgroundColor: AutoFlowTokens.errorFg,
            foregroundColor: AutoFlowTokens.errorBg,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(AfRadius.card),
            ),
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: AfRadius.cardAll,
          boxShadow: AutoFlowTokens.cardShadow,
        ),
        child: Material(
          color: tokens.card,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: AfRadius.cardAll,
            side: BorderSide(color: tokens.line),
          ),
          child: InkWell(
            onTap: () => _openInvoice(context),
            onLongPress: () => _showActionSheet(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AfSpace.m16,
                AfSpace.m16,
                AfSpace.s8,
                AfSpace.xs4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AfSpace.s8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.ownerName.isEmpty
                                    ? 'Unnamed Owner'
                                    : summary.ownerName,
                                style: AutoFlowTokens.title.copyWith(
                                  color: tokens.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (phoneNumber.isNotEmpty) ...[
                                const SizedBox(height: AfSpace.xs4),
                                Text(
                                  phoneNumber,
                                  style: AutoFlowTokens.mono(
                                    color: tokens.mute,
                                  ),
                                ),
                              ],
                              if (vehicleLine.isNotEmpty) ...[
                                const SizedBox(height: AfSpace.xs4),
                                Text(vehicleLine, style: metaStyle),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AfSpace.s12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '#${summary.id.substring(0, 8)}',
                              style: AutoFlowTokens.mono(color: tokens.mute),
                            ),
                            if (summary.totalAmount != null) ...[
                              const SizedBox(height: AfSpace.xs4),
                              Text(
                                formatAud(summary.totalAmount!),
                                style: AutoFlowTokens.mono(
                                  fontSize: 17,
                                  color: tokens.ink,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AfSpace.s12),
                  Wrap(
                    spacing: AfSpace.s8,
                    runSpacing: AfSpace.s8,
                    children: [
                      isCompleted
                          ? AfStatusChip(
                              label: summary.serviceStatus.label,
                              background: AutoFlowTokens.successBg,
                              foreground: AutoFlowTokens.successFg,
                            )
                          : AfStatusChip(
                              label: summary.serviceStatus.label,
                              background: AutoFlowTokens.warningBg,
                              foreground: AutoFlowTokens.warningFg,
                            ),
                      isPaid
                          ? AfStatusChip(
                              label: summary.paymentStatus.label,
                              background: AutoFlowTokens.successBg,
                              foreground: AutoFlowTokens.successFg,
                            )
                          : AfStatusChip(
                              label: summary.paymentStatus.label,
                              background: AutoFlowTokens.errorBg,
                              foreground: AutoFlowTokens.errorFg,
                            ),
                    ],
                  ),
                  const SizedBox(height: AfSpace.s12),
                  Padding(
                    padding: const EdgeInsets.only(right: AfSpace.s8),
                    child: Divider(color: tokens.line, height: 1, thickness: 1),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Updated '),
                              TextSpan(
                                text: formatInvoiceDateTime(summary.updatedAt),
                                style: AutoFlowTokens.mono(
                                  fontSize: 13,
                                  color: tokens.mute,
                                ),
                              ),
                            ],
                          ),
                          style: metaStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: isCompleted
                            ? 'Undo Complete Service'
                            : 'Complete Service',
                        color: tokens.ink,
                        onPressed: () => context.read<InvoiceBloc>().add(
                          isCompleted
                              ? InvoiceServiceReverted(summary.id)
                              : InvoiceServiceCompleted(summary.id),
                        ),
                        icon: Icon(
                          isCompleted ? Icons.undo : Icons.check_circle_outline,
                        ),
                      ),
                      IconButton(
                        tooltip: isPaid ? 'Undo Payment' : 'Mark Paid',
                        color: tokens.ink,
                        onPressed: () => _confirmMarkPaid(context),
                        icon: Icon(isPaid ? Icons.undo : Icons.attach_money),
                      ),
                      IconButton(
                        tooltip: 'Generate PDF',
                        color: tokens.ink,
                        onPressed: () => _generatePdf(context),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One 48px+ row in the long-press action sheet.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AutoFlowTokens.of(context).ink;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AfSpace.l24),
      leading: Icon(icon, color: fg),
      title: Text(
        label,
        style: AutoFlowTokens.body.copyWith(
          color: fg,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
