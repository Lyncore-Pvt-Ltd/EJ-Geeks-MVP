import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/invoice/domain/entities/invoice_line_item.dart';
import 'package:flutter/material.dart';

class InvoiceLineItemCard extends StatelessWidget {
  const InvoiceLineItemCard({
    super.key,
    required this.item,
    required this.onRemove,
  });

  final InvoiceLineItem item;
  final VoidCallback onRemove;

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Description',
                style: TextStyle(fontSize: 12, color: labelColor),
              ),
              InkWell(
                onTap: onRemove,
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppPallete.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            item.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(fontSize: 12, color: labelColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _trimmed(item.quantity),
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit per-price',
                      style: TextStyle(fontSize: 12, color: labelColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${_trimmed(item.unitPrice)}',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 10),
          Text(
            'Total price',
            style: TextStyle(fontSize: 12, color: labelColor),
          ),
          const SizedBox(height: 2),
          Text(
            '\$${_trimmed(item.totalPrice)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
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
