import 'package:ej_geek/core/presentation/widget/show_delete_dialog.dart';
import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/invoice/data/constants/invoice_date_format.dart';
import 'package:ej_geek/features/invoice/domain/entities/invoice_summary.dart';
import 'package:ej_geek/features/invoice/domain/entities/payment_status.dart';
import 'package:ej_geek/features/invoice/domain/entities/service_status.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.summary});

  final InvoiceSummary summary;

  Future<void> _openInvoice(BuildContext context) async {
    final invoiceBloc = context.read<InvoiceBloc>();
    await InvoiceBottomSheet.show(context, invoiceId: summary.id);
    invoiceBloc.add(const InvoiceListRequested());
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final invoiceBloc = context.read<InvoiceBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ShowDeleteDialog(
        title: 'Delete Invoice',
        message:
            'Are you sure you want to delete this invoice? '
            'Its inspection details and photos will also be removed.',
      ),
    );
    if (confirmed == true) {
      invoiceBloc.add(InvoiceDeleted(summary.id));
    }
  }

  void _showGeneratePdfStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generation coming soon')),
    );
  }

  void _showActionSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final groupColor = isDark ? AppPallete.warmOnyx : Colors.grey[200];
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final handleColor = isDark ? Colors.white24 : Colors.black26;
    final vehicleLine = [
      summary.make,
      summary.model,
      summary.rego,
    ].where((part) => part.isNotEmpty).join(' · ');
    final sheetTitle = summary.ownerName.isEmpty
        ? (vehicleLine.isEmpty ? 'Invoice #${summary.id.substring(0, 8)}' : vehicleLine)
        : summary.ownerName;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppPallete.dynamicBlack, AppPallete.warmOnyx, AppPallete.dynamicBlack]
                : [Colors.grey[200]!, Colors.grey[100]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                sheetTitle,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: groupColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openInvoice(context);
                    },
                    leading: Icon(Icons.edit, color: textColor),
                    title: Text(
                      'Edit',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(
                    color: dividerColor,
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                    enabled: summary.serviceStatus != ServiceStatus.completed,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.read<InvoiceBloc>().add(
                        InvoiceServiceCompleted(summary.id),
                      );
                    },
                    leading: Icon(Icons.check_circle_outline, color: textColor),
                    title: Text(
                      'Complete Service',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(
                    color: dividerColor,
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showGeneratePdfStub(context);
                    },
                    leading: Icon(Icons.picture_as_pdf_outlined, color: textColor),
                    title: Text(
                      'Generate PDF',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(
                    color: dividerColor,
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _confirmDelete(context);
                    },
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleLine = [
      summary.make,
      summary.model,
      summary.rego,
    ].where((part) => part.isNotEmpty).join(' · ');

    return Slidable(
      key: ValueKey(summary.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (context) => _showActionSheet(context),
            backgroundColor: isDark
                ? AppPallete.warmOnyx
                : AppPallete.nebulousWhite,
            foregroundColor: isDark
                ? AppPallete.cascadingWhite
                : AppPallete.tricornBlack,
            icon: Icons.more_horiz,
            label: 'More',
          ),
          SlidableAction(
            onPressed: (context) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openInvoice(context),
        onLongPress: () => _showActionSheet(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      summary.ownerName.isEmpty
                          ? 'Unnamed Owner'
                          : summary.ownerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppPallete.cascadingWhite
                            : AppPallete.tricornBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '#${summary.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppPallete.boatAnchor
                          : AppPallete.hypnotic,
                    ),
                  ),
                ],
              ),
              if (vehicleLine.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  vehicleLine,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppPallete.boatAnchor
                        : AppPallete.hypnotic,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Updated ${formatInvoiceDateTime(summary.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppPallete.boatAnchor : AppPallete.hypnotic,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusBadge(
                    label: summary.serviceStatus.label,
                    color: summary.serviceStatus == ServiceStatus.completed
                        ? Colors.green
                        : Colors.amber,
                  ),
                  _StatusBadge(
                    label: summary.paymentStatus.label,
                    color: summary.paymentStatus == PaymentStatus.paid
                        ? Colors.green
                        : Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Complete Service',
                    onPressed: summary.serviceStatus == ServiceStatus.completed
                        ? null
                        : () => context.read<InvoiceBloc>().add(
                            InvoiceServiceCompleted(summary.id),
                          ),
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'Generate PDF',
                    onPressed: () => _showGeneratePdfStub(context),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
