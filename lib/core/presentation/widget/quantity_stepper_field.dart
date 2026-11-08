import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';

/// A numeric [TextEditingController]-backed field with +/- step buttons.
/// Typing a value directly still works — the buttons are a convenience on
/// top of the same controller, not a replacement for typing.
class QuantityStepperField extends StatefulWidget {
  const QuantityStepperField({
    super.key,
    required this.controller,
    required this.label,
    this.step = 1,
  });

  final TextEditingController controller;
  final String label;
  final double step;

  @override
  State<QuantityStepperField> createState() => _QuantityStepperFieldState();
}

class _QuantityStepperFieldState extends State<QuantityStepperField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  double get _value => double.tryParse(widget.controller.text) ?? 0;

  String _trimmed(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  void _setValue(double value) {
    final clamped = value < 0 ? 0.0 : value;
    widget.controller.text = _trimmed(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AfRadius.controlAll,
          borderSide: BorderSide(color: color, width: width),
        );

    // Same DESIGN.md text-field spec as InspectionTextField (label above,
    // 48px field) so the two line up when placed side by side in a Row.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AfSpace.m16),
          child: ExcludeSemantics(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AutoFlowTokens.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: tokens.mute,
              ),
            ),
          ),
        ),
        const SizedBox(height: AfSpace.s8),
        Row(
          children: [
            _StepButton(
              icon: Icons.remove,
              tooltip: 'Decrease ${widget.label}',
              onTap: _value <= 0 ? null : () => _setValue(_value - widget.step),
            ),
            const SizedBox(width: AfSpace.s8),
            Expanded(
              // The visible label above is excluded; announce it here.
              child: Semantics(
                label: widget.label,
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  textAlign: TextAlign.center,
                  cursorColor: AutoFlowTokens.accent,
                  style: AutoFlowTokens.mono(
                    fontSize: 16,
                    color: tokens.ink,
                  ).copyWith(height: 1.2),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: tokens.card,
                    // 16px text at 1.2 line height + 14px top/bottom ≈ 48px.
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AfSpace.s8,
                      vertical: 14,
                    ),
                    enabledBorder: border(tokens.line),
                    disabledBorder: border(tokens.line),
                    focusedBorder: border(AutoFlowTokens.accent, 1.5),
                    errorBorder: border(AutoFlowTokens.errorFg),
                    focusedErrorBorder: border(AutoFlowTokens.errorFg, 1.5),
                    border: border(tokens.line),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AfSpace.s8),
            _StepButton(
              icon: Icons.add,
              tooltip: 'Increase ${widget.label}',
              onTap: () => _setValue(_value + widget.step),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final disabled = onTap == null;

    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        enabled: !disabled,
        label: tooltip,
        excludeSemantics: true,
        child: AfPressable(
          onTap: onTap,
          child: Container(
            height: AfSpace.controlHeight,
            width: AfSpace.minTap,
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: AfRadius.controlAll,
              border: Border.all(color: tokens.line),
            ),
            child: Icon(
              icon,
              size: 18,
              color: disabled ? tokens.line : tokens.ink,
            ),
          ),
        ),
      ),
    );
  }
}
