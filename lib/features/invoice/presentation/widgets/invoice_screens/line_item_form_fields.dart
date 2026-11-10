import 'package:auto_flow/core/presentation/widget/cents_currency_input_formatter.dart';
import 'package:auto_flow/core/presentation/widget/quantity_stepper_field.dart';
import 'package:auto_flow/features/inspection/presentation/widgets/inspection_text_field.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

/// Name / Quantity / Unit per-price fields shared between the invoice tab's
/// add-item form and the edit-item dialog.
class LineItemFormFields extends StatelessWidget {
  const LineItemFormFields({
    super.key,
    required this.nameController,
    required this.qtyController,
    required this.priceController,
  });

  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectionTextField(controller: nameController, label: 'Items Name'),
        const SizedBox(height: AfSpace.m16),
        Row(
          // Both fields put a 13px label above a 48px control, so aligning
          // their tops keeps labels and boxes level (and a validation line
          // under one field doesn't shift the other).
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: QuantityStepperField(
                controller: qtyController,
                label: 'Quantity',
              ),
            ),
            const SizedBox(width: AfSpace.s12),
            Expanded(
              child: InspectionTextField(
                controller: priceController,
                label: 'Unit per-price',
                prefixText: 'A\$ ',
                keyboardType: TextInputType.number,
                inputFormatters: [CentsCurrencyInputFormatter()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
