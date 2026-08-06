import 'package:flutter/material.dart';

import '../../../../core/theme/app_pallete.dart';

/// A single selectable option in a [FilterBottomSheet].
class FilterOption<T> {
  const FilterOption({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final T value;
}

/// A reusable, generic single-select filter sheet: rounded gradient
/// container, grabber handle, grouped [ListTile]s with dividers — the same
/// visual pattern used by [InvoiceCard]'s action sheet. Has no knowledge of
/// what [T] represents; callers supply the options, the current selection,
/// and what to do when one is picked.
class FilterBottomSheet<T> extends StatelessWidget {
  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.activeValue,
    required this.onSelected,
  });

  final String title;
  final List<FilterOption<T>> options;
  final T activeValue;
  final ValueChanged<T> onSelected;

  static Future<void> show<T>({
    required BuildContext context,
    required String title,
    required List<FilterOption<T>> options,
    required T activeValue,
    required ValueChanged<T> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet<T>(
        title: title,
        options: options,
        activeValue: activeValue,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final groupColor = isDark ? AppPallete.warmOnyx : Colors.grey[200];
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final handleColor = isDark ? Colors.white24 : Colors.black26;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? AppPallete.invoiceCardGradientDark
              : AppPallete.invoiceCardGradientLight,
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
              title,
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
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
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0)
                    Divider(
                      color: dividerColor,
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                  _FilterTile<T>(
                    option: options[i],
                    isActive: options[i].value == activeValue,
                    textColor: textColor,
                    onSelected: onSelected,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FilterTile<T> extends StatelessWidget {
  const _FilterTile({
    required this.option,
    required this.isActive,
    required this.textColor,
    required this.onSelected,
  });

  final FilterOption<T> option;
  final bool isActive;
  final Color textColor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        onSelected(option.value);
      },
      leading: Icon(
        option.icon,
        color: isActive ? AppPallete.emeraldTeal : textColor,
      ),
      title: Text(
        option.label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: isActive
          ? const Icon(Icons.check, color: AppPallete.emeraldTeal)
          : null,
    );
  }
}
