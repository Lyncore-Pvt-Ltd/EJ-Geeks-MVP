import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_gradient_button.dart';
import 'package:ej_geek/features/invoice/domain/entities/invoice_line_item.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_event.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/line_item_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dialog for editing an already-added [InvoiceLineItem]'s name/quantity/price.
class EditLineItemDialog extends StatefulWidget {
  const EditLineItemDialog({super.key, required this.item});

  final InvoiceLineItem item;

  static Future<void> show(BuildContext context, InvoiceLineItem item) async {
    final bloc = context.read<InvoiceDetailsBloc>();
    await showDialog<void>(
      context: context,
      builder: (_) =>
          BlocProvider.value(value: bloc, child: EditLineItemDialog(item: item)),
    );
  }

  @override
  State<EditLineItemDialog> createState() => _EditLineItemDialogState();
}

class _EditLineItemDialogState extends State<EditLineItemDialog> {
  late final _nameController = TextEditingController(text: widget.item.name);
  late final _qtyController = TextEditingController(
    text: trimmedAmount(widget.item.quantity),
  );
  late final _priceController = TextEditingController(
    text: widget.item.unitPrice.toStringAsFixed(2),
  );

  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final name = _nameController.text.trim();
    final quantity = double.tryParse(_qtyController.text) ?? 0;
    final unitPrice = double.tryParse(_priceController.text) ?? 0;

    if (name.isEmpty || quantity <= 0 || unitPrice <= 0) {
      setState(
        () => _errorText = 'Enter a valid name, quantity and unit price.',
      );
      return;
    }

    context.read<InvoiceDetailsBloc>().add(
      LineItemEdited(
        itemId: widget.item.id,
        name: name,
        quantityRaw: _qtyController.text,
        unitPriceRaw: _priceController.text,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final backgroundColor = isDark
        ? AppPallete.dynamicBlack
        : AppPallete.whiteout;

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Item',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_outlined, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LineItemFormFields(
              nameController: _nameController,
              qtyController: _qtyController,
              priceController: _priceController,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppPallete.errorColor.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppPallete.errorColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style: const TextStyle(
                          color: AppPallete.errorColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            InspectionGradientButton(
              label: 'Save changes',
              onTap: () => _save(context),
            ),
          ],
        ),
      ),
    );
  }
}
