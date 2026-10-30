import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import 'af_busy_label.dart';
import 'af_motion.dart';
import 'af_spinner.dart';

/// Full-width 48px accent button with an optional busy state.
class AfPrimaryButton extends StatelessWidget {
  final String label;
  final String? busyLabel;
  final bool busy;
  final bool showArrow;
  final VoidCallback? onPressed;

  /// Border tint; the success screen uses a light one on its dark ground.
  final Color borderColor;

  const AfPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busyLabel,
    this.busy = false,
    this.showArrow = false,
    this.borderColor = const Color(0x1214213D),
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: AutoFlowTokens.fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.17,
      color: AutoFlowTokens.onAccent,
    );
    return Semantics(
      button: true,
      label: busy ? busyLabel : label,
      child: AfPressable(
        onTap: busy ? null : onPressed,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AutoFlowTokens.accent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
            boxShadow: AutoFlowTokens.accentShadow,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // Stand-in for the design's inset 1px top highlight.
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x47FFFFFF), Color(0x00FFFFFF)],
              stops: [0, 0.06],
            ),
          ),
          child: DefaultTextStyle(
            style: textStyle,
            // Long labels shrink rather than overflow on narrow phones.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AfBusyLabel(
                    busy: busy,
                    idle: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label),
                        if (showArrow) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AutoFlowTokens.onAccent,
                          ),
                        ],
                      ],
                    ),
                    loading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(busyLabel ?? label),
                        const SizedBox(width: 8),
                        const AfSpinner(
                          size: 18,
                          color: AutoFlowTokens.onAccent,
                          track: Color(0x40000000),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
