import 'package:auto_flow/core/presentation/widget/show_delete_dialog.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_line_item.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:flutter/material.dart';

class InvoiceLineItemCard extends StatelessWidget {
  const InvoiceLineItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onRemove,
  });

  final InvoiceLineItem item;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  Future<void> _confirmDelete(BuildContext context) async {
    final result = await showDialog<DeleteDialogResult>(
      context: context,
      builder: (_) => const ShowDeleteDialog(),
    );
    if (result?.confirmed == true) onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final labelStyle = AutoFlowTokens.caption.copyWith(color: tokens.mute);
    final valueStyle = AutoFlowTokens.mono(color: tokens.ink);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AfSpace.xs4),
      padding: const EdgeInsets.fromLTRB(
        AfSpace.m16,
        AfSpace.xs4,
        AfSpace.xs4,
        AfSpace.m16,
      ),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AfRadius.cardAll,
        border: Border.all(color: tokens.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Description', style: labelStyle)),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit item',
                iconSize: 20,
                color: tokens.ink,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => _confirmDelete(context),
                tooltip: 'Delete item',
                iconSize: 20,
                color: AutoFlowTokens.errorFg,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: AfSpace.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AutoFlowTokens.title.copyWith(color: tokens.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AfSpace.s12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity', style: labelStyle),
                          const SizedBox(height: AfSpace.xs4),
                          Text(_trimmed(item.quantity), style: valueStyle),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unit per-price', style: labelStyle),
                          const SizedBox(height: AfSpace.xs4),
                          Text(formatAud(item.unitPrice), style: valueStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AfSpace.s12),
                Divider(color: tokens.line, height: 1, thickness: 1),
                const SizedBox(height: AfSpace.s12),
                Text('Total price', style: labelStyle),
                const SizedBox(height: AfSpace.xs4),
                Text(
                  formatAud(item.totalPrice),
                  style: AutoFlowTokens.mono(fontSize: 17, color: tokens.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _trimmed(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }
}
