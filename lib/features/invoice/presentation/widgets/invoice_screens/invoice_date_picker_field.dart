import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/invoice/data/constants/invoice_date_format.dart';
import 'package:flutter/material.dart';

class InvoiceDatePickerField extends StatelessWidget {
  const InvoiceDatePickerField({
    super.key,
    required this.label,
    required this.date,
    required this.onPicked,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPicked;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final dateText = date != null ? formatInvoiceDate(date!) : 'Choose date';

    // Same DESIGN.md text-field spec as InspectionTextField: 13px/500 muted
    // label above (16px inset), 8px gap, 48px control.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AfSpace.m16),
          child: ExcludeSemantics(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AutoFlowTokens.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: tokens.mute,
              ),
            ),
          ),
        ),
        const SizedBox(height: AfSpace.s8),
        Semantics(
          button: true,
          label: '$label, $dateText',
          excludeSemantics: true,
          child: Material(
            color: tokens.card,
            shape: RoundedRectangleBorder(
              borderRadius: AfRadius.controlAll,
              side: BorderSide(color: tokens.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _pickDate(context),
              child: SizedBox(
                height: AfSpace.controlHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AfSpace.m16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: date != null
                              ? AutoFlowTokens.mono(
                                  fontSize: 16,
                                  color: tokens.ink,
                                )
                              : AutoFlowTokens.body.copyWith(
                                  color: tokens.mute,
                                ),
                        ),
                      ),
                      const SizedBox(width: AfSpace.s8),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: tokens.mute2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
