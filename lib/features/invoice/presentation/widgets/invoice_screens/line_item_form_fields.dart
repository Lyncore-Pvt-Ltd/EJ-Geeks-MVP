import 'package:ej_geek/core/presentation/widget/quantity_stepper_field.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: QuantityStepperField(
                controller: qtyController,
                label: 'Quantity',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InspectionTextField(
                controller: priceController,
                label: 'Unit per-price',
                prefixText: 'A\$ ',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
