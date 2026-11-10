import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// Borderless 44×44 icon action for toolbars, card footers and dialog
/// headers (Save, Delete, Generate PDF…). Press scales to 0.94 and fills
/// with the soft colour — no Material ink. For the bordered Back button use
/// `AfIconButton`; for toggles inside a field use `AfInlineIconButton`.
///
/// Swapping the content (icon ↔ spinner ↔ check) crossfades over 200ms.
class AfToolbarIconButton extends StatelessWidget {
  final IconData? icon;

  /// Custom content in place of [icon] (e.g. an `AfSpinner` while saving).
  /// Give it a key so a swap crossfades.
  final Widget? child;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const AfToolbarIconButton({
    super.key,
    required IconData this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.size = 22,
  }) : child = null;

  const AfToolbarIconButton.custom({
    super.key,
    required Widget this.child,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.size = 22,
  }) : icon = null;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final enabled = onPressed != null;
    final iconColor = color ?? tokens.ink;
    final resolvedColor = enabled
        ? iconColor
        : iconColor.withValues(alpha: iconColor.a * 0.4);
    final content =
        child ??
        Icon(icon, key: ValueKey(icon), size: size, color: resolvedColor);
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        onTap: onPressed,
        excludeSemantics: true,
        child: AfPressable.builder(
          onTap: onPressed,
          pressedScale: 0.94,
          builder: (context, pressed) => AnimatedContainer(
            duration: afDuration(context, 160),
            curve: AutoFlowTokens.easeOut,
            width: AfSpace.minTap,
            height: AfSpace.minTap,
            decoration: BoxDecoration(
              color: pressed ? tokens.soft : tokens.soft.withValues(alpha: 0),
              borderRadius: AfRadius.controlAll,
            ),
            alignment: Alignment.center,
            child: IconTheme.merge(
              data: IconThemeData(color: resolvedColor, size: size),
              child: AnimatedSwitcher(
                duration: afDuration(context, 200),
                switchInCurve: AutoFlowTokens.easeOut,
                switchOutCurve: AutoFlowTokens.easeOut,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
