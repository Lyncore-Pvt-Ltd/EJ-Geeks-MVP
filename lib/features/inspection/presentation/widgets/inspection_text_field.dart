import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared inspection input field, styled with [AppPallete.selectionGradient]
/// on focus. Two usage modes:
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

  Widget? get _suffixIcon {
    if (widget.readOnly && widget.onEditTap != null) {
      return IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: widget.onEditTap,
      );
    }
    if (!widget.readOnly &&
        widget.onSaveTap != null &&
        (widget.controller?.text.trim().isNotEmpty ?? false)) {
      return IconButton(
        icon: const Icon(Icons.check_circle_outline),
        onPressed: widget.onSaveTap,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = AppPallete.selectionGradient[1];
    final collapsed = widget.growable ? widget.collapsedLines : 1;
    final expanded = widget.growable ? widget.expandedLines : 1;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
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
          initialValue: widget.controller == null ? widget.initialValue : null,
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
          cursorColor: highlightColor,
          selectionControls: materialTextSelectionControls,
          style: TextStyle(
            color: isDark
                ? AppPallete.cascadingWhite
                : AppPallete.tricornBlack,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            prefixText: widget.prefixText,
            suffixIcon: _suffixIcon,
            isDense: true,
            labelStyle: TextStyle(
              color: _isFocused
                  ? highlightColor
                  : (isDark ? AppPallete.boatAnchor : AppPallete.hypnotic),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: highlightColor, width: 1.5),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}
