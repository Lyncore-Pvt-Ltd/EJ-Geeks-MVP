import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import 'af_motion.dart';

/// 48px text field with a 13px label above and an animated error line below.
/// Focus draws an accent border; an error draws a red one.
class AfTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  const AfTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final hasError = errorText != null;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            label,
            style: AutoFlowTokens.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: tokens.mute,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            cursorColor: AutoFlowTokens.accent,
            style: AutoFlowTokens.body.copyWith(color: tokens.ink, height: 1.2),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AutoFlowTokens.body.copyWith(
                color: tokens.mute,
                height: 1.2,
              ),
              filled: true,
              fillColor: tokens.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: border(
                hasError ? AutoFlowTokens.errorFg : tokens.line,
              ),
              focusedBorder: border(AutoFlowTokens.accent, 1.5),
              suffixIcon: trailing,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: afDuration(context, 200),
          curve: AutoFlowTokens.easeOut,
          alignment: Alignment.topCenter,
          child: hasError
              ? AfReveal(
                  visible: true,
                  dy: -4,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 14,
                          color: AutoFlowTokens.errorFg,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorText!,
                            style: AutoFlowTokens.caption.copyWith(
                              color: AutoFlowTokens.errorFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
