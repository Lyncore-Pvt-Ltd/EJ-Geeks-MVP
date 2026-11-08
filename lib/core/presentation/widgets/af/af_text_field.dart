import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
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

  /// Turn both off for emails, codes and other non-prose input.
  final bool autocorrect;
  final bool enableSuggestions;

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
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final hasError = errorText != null;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AfRadius.controlAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          // Read as the field's own label instead (see the Semantics below).
          child: ExcludeSemantics(
            child: Text(
              label,
              style: AutoFlowTokens.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: tokens.mute,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: Semantics(
            label: label,
            // The error is part of the field's description while it shows.
            hint: errorText,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              autofillHints: autofillHints,
              autocorrect: autocorrect,
              enableSuggestions: enableSuggestions,
              cursorColor: AutoFlowTokens.accent,
              style: AutoFlowTokens.body.copyWith(
                color: tokens.ink,
                height: 1.2,
              ),
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
                // Keep the red border while an error shows, even when focused.
                focusedBorder: border(
                  hasError ? AutoFlowTokens.errorFg : AutoFlowTokens.accent,
                  1.5,
                ),
                suffixIcon: trailing,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
            ),
          ),
        ),
        // The error line slides/fades in; a new message re-animates (keyed
        // by text) and clearing it fades out while the height collapses.
        AnimatedSize(
          duration: afDuration(context, 200),
          curve: AutoFlowTokens.easeOut,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: afDuration(context, 200),
            switchInCurve: AutoFlowTokens.easeOut,
            switchOutCurve: AutoFlowTokens.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topLeft,
              children: [...previous, ?current],
            ),
            child: hasError
                ? _ErrorLine(key: ValueKey(errorText), text: errorText!)
                : const SizedBox(
                    key: ValueKey('no-error'),
                    width: double.infinity,
                  ),
          ),
        ),
      ],
    );
  }
}

/// Alert icon + message under a field; announced as it appears (it's also
/// read as the field's hint).
class _ErrorLine extends StatelessWidget {
  final String text;

  const _ErrorLine({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
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
                text,
                style: AutoFlowTokens.caption.copyWith(
                  color: AutoFlowTokens.errorFg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
