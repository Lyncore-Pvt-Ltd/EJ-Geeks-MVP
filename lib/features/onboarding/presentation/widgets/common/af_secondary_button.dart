import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
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
    return Semantics(
      button: true,
      label: busy ? busyLabel : label,
      child: AfPressable(
        onTap: busy ? null : onPressed,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0x0DFCA311),
            borderRadius: BorderRadius.circular(10),
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
    );
  }
}
