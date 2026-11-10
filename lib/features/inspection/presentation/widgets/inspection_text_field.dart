import 'package:auto_flow/core/presentation/widgets/af/af_inline_icon_button.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared inspection input field, styled per the DESIGN.md text field spec
/// (48px, radius 10, 1px line border, card fill, 13px muted label above,
/// accent focus border). Two usage modes:
/// - controlled, single-line (Vehicle Details): pass [controller].
/// - uncontrolled, grows while typing (section Comments): pass
///   [initialValue] + [onChanged] and [growable]: true.
class InspectionTextField extends StatefulWidget {
  const InspectionTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    required this.label,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.growable = false,
    this.collapsedLines = 3,
    this.expandedLines = 6,
    this.prefixText,
    this.validator,
    this.readOnly = false,
    this.onEditTap,
    this.onSaveTap,
  }) : assert(
         controller == null || initialValue == null,
         'Pass either controller or initialValue, not both.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String label;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool growable;
  final int collapsedLines;
  final int expandedLines;
  final String? prefixText;
  final FormFieldValidator<String>? validator;

  /// When true, the field is non-editable and shows an edit-icon suffix
  /// (if [onEditTap] is provided) instead of accepting direct input.
  final bool readOnly;

  /// Called when the user taps the edit icon on a [readOnly] field. Has no
  /// effect unless [readOnly] is also true.
  final VoidCallback? onEditTap;

  /// Called when the user taps the save icon shown while the field is
  /// editable and non-empty. Has no effect when [readOnly] is true.
  final VoidCallback? onSaveTap;

  @override
  State<InspectionTextField> createState() => _InspectionTextFieldState();
}

class _InspectionTextFieldState extends State<InspectionTextField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    if (widget.controller != null && widget.onSaveTap != null) {
      widget.controller!.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() => setState(() {});

  Widget _suffixButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: AfInlineIconButton(
        icon: icon,
        semanticLabel: tooltip,
        onPressed: onPressed,
        color: color,
      ),
    );
  }

  Widget? _suffixIcon(AutoFlowTokens tokens) {
    if (widget.readOnly && widget.onEditTap != null) {
      return _suffixButton(
        icon: Icons.edit_outlined,
        tooltip: 'Edit ${widget.label}',
        onPressed: widget.onEditTap,
        color: tokens.mute2,
      );
    }
    if (!widget.readOnly &&
        widget.onSaveTap != null &&
        (widget.controller?.text.trim().isNotEmpty ?? false)) {
      return _suffixButton(
        icon: Icons.check_circle_outline,
        tooltip: 'Save ${widget.label}',
        onPressed: widget.onSaveTap,
        color: tokens.ink,
      );
    }
    return null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller != null && widget.onSaveTap != null) {
      widget.controller!.removeListener(_onControllerChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final collapsed = widget.growable ? widget.collapsedLines : 1;
    final expanded = widget.growable ? widget.expandedLines : 1;
    final textStyle = AutoFlowTokens.body.copyWith(
      color: widget.readOnly ? tokens.mute2 : tokens.ink,
      height: 1.2,
    );

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AfRadius.controlAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AfSpace.m16),
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
        const SizedBox(height: AfSpace.s8),
        AnimatedSize(
          duration: afDuration(context, 200),
          curve: AutoFlowTokens.easeOut,
          alignment: Alignment.topCenter,
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: AutoFlowTokens.accent,
                selectionColor: AutoFlowTokens.accent.withValues(alpha: 0.32),
                selectionHandleColor: AutoFlowTokens.accent,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              initialValue: widget.controller == null
                  ? widget.initialValue
                  : null,
              focusNode: _focusNode,
              minLines: collapsed,
              maxLines: _isFocused ? expanded : collapsed,
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              inputFormatters: widget.inputFormatters,
              validator: widget.validator,
              readOnly: widget.readOnly,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              cursorColor: AutoFlowTokens.accent,
              selectionControls: materialTextSelectionControls,
              style: textStyle,
              decoration: InputDecoration(
                prefixText: widget.prefixText,
                prefixStyle: textStyle.copyWith(color: tokens.mute2),
                suffixIcon: _suffixIcon(tokens),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: AfSpace.controlHeight,
                  minHeight: AfSpace.controlHeight,
                ),
                isDense: true,
                filled: true,
                fillColor: widget.readOnly ? tokens.soft : tokens.card,
                // 16px text at 1.2 line height + 14px top/bottom ≈ 48px.
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AfSpace.m16,
                  vertical: 14,
                ),
                errorStyle: AutoFlowTokens.caption.copyWith(
                  color: AutoFlowTokens.errorFg,
                ),
                enabledBorder: border(tokens.line),
                disabledBorder: border(tokens.line),
                focusedBorder: border(
                  widget.readOnly ? tokens.line : AutoFlowTokens.accent,
                  widget.readOnly ? 1 : 1.5,
                ),
                errorBorder: border(AutoFlowTokens.errorFg),
                focusedErrorBorder: border(AutoFlowTokens.errorFg, 1.5),
                border: border(tokens.line),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
