import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

/// Equal-width row of dialog action buttons (e.g. `AfSecondaryButton` +
/// `AfPrimaryButton`). Pass it as the only entry of `AlertDialog.actions`.
class DialogActions extends StatelessWidget {
  final List<Widget> children;

  const DialogActions({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: AfSpace.s12),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

/// Padding for [DialogActions] inside an `AlertDialog`.
const EdgeInsets kDialogActionsPadding = EdgeInsets.fromLTRB(
  AfSpace.l24,
  0,
  AfSpace.l24,
  AfSpace.l24,
);

/// Destructive twin of `AfPrimaryButton`: 48px, control radius, errorFg fill,
/// white label with an optional trailing icon.
class DestructiveButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const DestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  static const Color _onError = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: AfPressable(
        onTap: onPressed,
        child: Container(
          height: AfSpace.controlHeight,
          padding: const EdgeInsets.symmetric(horizontal: AfSpace.m16),
          decoration: const BoxDecoration(
            color: AutoFlowTokens.errorFg,
            borderRadius: AfRadius.controlAll,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AutoFlowTokens.title.copyWith(color: _onError),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: AfSpace.s8),
                    Icon(icon, size: 18, color: _onError),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
