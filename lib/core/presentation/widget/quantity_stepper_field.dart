import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_pallete.dart';

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
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = AppPallete.selectionGradient[1];
    final borderColor = isDark
        ? AppPallete.warmOnyx
        : AppPallete.nebulousWhite;
    final labelColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _StepButton(
          icon: Icons.remove,
          borderColor: borderColor,
          onTap: _value <= 0 ? null : () => _setValue(_value - widget.step),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: highlightColor,
                selectionColor: highlightColor.withValues(alpha: 0.4),
                selectionHandleColor: highlightColor,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              cursorColor: highlightColor,
              style: TextStyle(
                color: isDark
                    ? AppPallete.cascadingWhite
                    : AppPallete.tricornBlack,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                isDense: true,
                labelStyle: TextStyle(
                  color: _isFocused ? highlightColor : labelColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: highlightColor, width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _StepButton(
          icon: Icons.add,
          borderColor: borderColor,
          onTap: () => _setValue(_value + widget.step),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabled = onTap == null;
    final iconColor = disabled
        ? borderColor
        : (isDark ? AppPallete.cascadingWhite : AppPallete.tricornBlack);

    return Material(
      color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}
