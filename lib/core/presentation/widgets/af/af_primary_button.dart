import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
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
    final onTap = busy ? null : onPressed;
    // Busy keeps its spinner look; only an idle, untappable button dims.
    final disabled = onPressed == null && !busy;
    return Semantics(
      button: true,
      enabled: onTap != null,
      // Announces the busy label when it swaps in.
      liveRegion: busy,
      label: busy ? (busyLabel ?? label) : label,
      onTap: onTap,
      // The visible label is already in [label]; don't read it twice.
      excludeSemantics: true,
      child: AnimatedOpacity(
        opacity: disabled ? 0.48 : 1,
        duration: afDuration(context, 150),
        curve: AutoFlowTokens.easeOut,
        child: AfPressable(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AutoFlowTokens.accent,
              borderRadius: AfRadius.controlAll,
              border: Border.all(color: borderColor),
              boxShadow: AutoFlowTokens.accentShadow,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: AfRadius.controlAll,
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
      ),
    );
  }
}
