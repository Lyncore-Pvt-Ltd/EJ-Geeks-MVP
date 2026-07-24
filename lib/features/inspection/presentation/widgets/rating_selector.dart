import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/rating_option.dart';

class RatingSelector extends StatelessWidget {
  const RatingSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final RatingOption? selected;
  final ValueChanged<RatingOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: RatingOption.values.map((option) {
        final isSelected = selected == option;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(option),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: AppPallete.selectionGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppPallete.whiteColor
                      : (isDark
                            ? AppPallete.cascadingWhite
                            : AppPallete.tricornBlack),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
