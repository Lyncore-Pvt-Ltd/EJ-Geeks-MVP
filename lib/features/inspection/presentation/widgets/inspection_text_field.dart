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
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
          cursorColor: highlightColor,
          selectionControls: materialTextSelectionControls,
          style: TextStyle(
            color: isDark
                ? AppPallete.cascadingWhite
                : AppPallete.tricornBlack,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
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
