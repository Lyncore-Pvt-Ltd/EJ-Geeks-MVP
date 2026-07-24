import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/invoice/data/constants/invoice_date_format.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final labelColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;
    final borderColor = isDark
        ? AppPallete.warmOnyx
        : AppPallete.nebulousWhite;

    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? formatInvoiceDate(date!) : 'Choose date',
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
                Icon(Icons.calendar_today_outlined, size: 16, color: labelColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
