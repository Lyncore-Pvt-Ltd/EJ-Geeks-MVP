import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';

/// Pill chip with a 6px leading dot.
class AfStatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Color? dotColor;

  const AfStatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.dotColor,
  });

  /// Colours for an inspection rating label (Good / Fair / Repair Required).
  factory AfStatusChip.rating(String rating) {
    final (bg, fg) = switch (rating) {
      'Good' => (AutoFlowTokens.successBg, AutoFlowTokens.successFg),
      'Fair' => (AutoFlowTokens.warningBg, AutoFlowTokens.warningFg),
      _ => (AutoFlowTokens.errorBg, AutoFlowTokens.errorFg),
    };
    return AfStatusChip(label: rating, background: bg, foreground: fg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor ?? foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            maxLines: 1,
            style: AutoFlowTokens.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
