import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../common/af_busy_label.dart';
import '../common/af_layout.dart';
import '../common/af_motion.dart';
import '../common/af_page_dots.dart';
import '../common/af_spinner.dart';

/// Page dots plus the large "Next →" / "Get started →" text button.
class IntroFooter extends StatelessWidget {
  final int count;
  final int index;
  final bool starting;
  final ValueChanged<int> onDotSelected;
  final VoidCallback onNext;

  const IntroFooter({
    super.key,
    required this.count,
    required this.index,
    required this.starting,
    required this.onDotSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final isLast = index == count - 1;
    final ctaSize = AfLayout.of(context).isCompact ? 24.0 : 28.0;
    final style = AutoFlowTokens.headline.copyWith(
      color: tokens.ink,
      fontSize: ctaSize,
      letterSpacing: -0.03 * ctaSize,
      height: 1,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, afBottomInset(context)),
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(-4, 0),
            child: AfPageDots(
              count: count,
              index: index,
              onSelected: onDotSelected,
            ),
          ),
          const SizedBox(width: 8),
          // Shrinks "Get started →" rather than overflowing on narrow phones.
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: _cta(context, tokens, style, isLast),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cta(
    BuildContext context,
    AutoFlowTokens tokens,
    TextStyle style,
    bool isLast,
  ) {
    final ctaSize = style.fontSize!;
    return Semantics(
      button: true,
      label: starting ? 'Opening' : (isLast ? 'Get started' : 'Next'),
      child: AfPressable(
        onTap: starting ? null : onNext,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: DefaultTextStyle(
              style: style,
              child: AfBusyLabel(
                busy: starting,
                alignment: Alignment.centerRight,
                idle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isLast ? 'Get started' : 'Next'),
                    const SizedBox(width: 8),
                    AnimatedSlide(
                      offset: Offset(isLast ? 4 / ctaSize : 0, 0),
                      duration: afDuration(context, 300),
                      curve: AutoFlowTokens.easeOut,
                      child: Icon(
                        Icons.arrow_forward_sharp,
                        size: ctaSize,
                        color: tokens.ink,
                      ),
                    ),
                  ],
                ),
                loading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Opening…'),
                    const SizedBox(width: 12),
                    AfSpinner(
                      size: 24,
                      strokeWidth: 2.5,
                      color: AutoFlowTokens.accent,
                      track: tokens.line,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
