import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'af_busy_label.dart';
import 'af_motion.dart';
import 'af_spinner.dart';

/// 48px button with a faint accent wash, ink label and optional leading icon.
class AfSecondaryButton extends StatelessWidget {
  final String label;
  final String? busyLabel;
  final IconData? icon;
  final bool busy;
  final VoidCallback? onPressed;

  const AfSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busyLabel,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
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
        child: AfPressable.builder(
          onTap: onTap,
          builder: (context, pressed) => AnimatedContainer(
            duration: afDuration(context, 160),
            curve: AutoFlowTokens.easeOut,
            height: 48,
            decoration: BoxDecoration(
              // Press deepens the accent wash from 5% to 10%.
              color: pressed
                  ? const Color(0x1AFCA311)
                  : const Color(0x0DFCA311),
              borderRadius: AfRadius.controlAll,
              border: Border.all(color: const Color(0x29FCA311)),
            ),
            child: DefaultTextStyle(
              style: AutoFlowTokens.title.copyWith(color: tokens.ink),
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
                          if (icon != null) ...[
                            Icon(icon, size: 18, color: tokens.ink),
                            const SizedBox(width: 8),
                          ],
                          Text(label),
                        ],
                      ),
                      loading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(busyLabel ?? label),
                          const SizedBox(width: 8),
                          AfSpinner(
                            size: 18,
                            color: tokens.ink,
                            track: tokens.line,
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
