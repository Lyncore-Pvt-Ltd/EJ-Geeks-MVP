import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/rating_option.dart';

/// Row of rating keys (DESIGN.md "Rating keys" + "Status chip"): idle keys
/// are outlined tiles with a status dot; the chosen key takes its status
/// colours (Good green, Fair amber, Repair red, N/A and N/C outlined in ink).
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
    return Wrap(
      spacing: AfSpace.s8,
      children: [
        for (final option in RatingOption.values)
          _RatingKey(
            option: option,
            isSelected: selected == option,
            onTap: () => onChanged(option),
          ),
      ],
    );
  }
}

class _RatingKey extends StatelessWidget {
  const _RatingKey({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final RatingOption option;
  final bool isSelected;
  final VoidCallback onTap;

  /// (soft background, foreground) for the chosen state; null = outline.
  (Color, Color)? get _status => switch (option) {
    RatingOption.good => (AutoFlowTokens.successBg, AutoFlowTokens.successFg),
    RatingOption.fair => (AutoFlowTokens.warningBg, AutoFlowTokens.warningFg),
    RatingOption.repair => (AutoFlowTokens.errorBg, AutoFlowTokens.errorFg),
    RatingOption.na || RatingOption.nc => null,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final status = _status;

    final Color fill;
    final Color border;
    final Color foreground;
    if (!isSelected) {
      fill = tokens.card;
      border = tokens.line;
      foreground = tokens.mute2;
    } else if (status != null) {
      fill = status.$1;
      border = status.$2.withValues(alpha: 0.32);
      foreground = status.$2;
    } else {
      fill = tokens.soft;
      border = tokens.ink;
      foreground = tokens.ink;
    }
    final dotColor = status?.$2;
    final duration = afDuration(context, 160);

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Rate ${option.label}',
      excludeSemantics: true,
      child: AfPressable(
        onTap: onTap,
        // 44px tall tap target around a 32px key.
        child: SizedBox(
          height: AfSpace.minTap,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: AutoFlowTokens.easeOut,
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: AfSpace.s12),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: AfRadius.keyAll,
                border: Border.all(color: border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: duration,
                    curve: AutoFlowTokens.easeOut,
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                      border: dotColor == null
                          ? Border.all(color: foreground)
                          : null,
                    ),
                  ),
                  const SizedBox(width: AfSpace.s8),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    curve: AutoFlowTokens.easeOut,
                    style: AutoFlowTokens.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: foreground,
                    ),
                    child: Text(option.label, maxLines: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
