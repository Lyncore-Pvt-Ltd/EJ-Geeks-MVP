import 'package:auto_flow/core/presentation/widgets/af/af_primary_button.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_line_item.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_bloc.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_event.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/line_item_form_fields.dart';
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
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: EditLineItemDialog(item: item),
      ),
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
    final tokens = AutoFlowTokens.of(context);

    return Dialog(
      backgroundColor: tokens.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AfRadius.cardAll,
        side: BorderSide(color: tokens.line),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AfSpace.gutter,
        vertical: AfSpace.l24,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AfSpace.l24,
          AfSpace.s12,
          AfSpace.s12,
          AfSpace.l24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit Item',
                    style: AutoFlowTokens.title.copyWith(color: tokens.ink),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  color: tokens.ink,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: AfSpace.s12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AfSpace.s8),
                  LineItemFormFields(
                    nameController: _nameController,
                    qtyController: _qtyController,
                    priceController: _priceController,
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: AfSpace.s12),
                    Semantics(
                      liveRegion: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AfSpace.s12,
                          vertical: AfSpace.s8,
                        ),
                        decoration: const BoxDecoration(
                          color: AutoFlowTokens.errorBg,
                          borderRadius: AfRadius.smallAll,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AutoFlowTokens.errorFg,
                              size: 16,
                            ),
                            const SizedBox(width: AfSpace.s8),
                            Expanded(
                              child: Text(
                                _errorText!,
                                style: AutoFlowTokens.caption.copyWith(
                                  color: AutoFlowTokens.errorFg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AfSpace.l24),
                  AfPrimaryButton(
                    label: 'Save changes',
                    onPressed: () => _save(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
