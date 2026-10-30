import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../common/af_motion.dart';

/// 20px checkbox (ink fill when checked, tick scales in) + "Keep me signed in".
class RememberCheckbox extends StatelessWidget {
  final bool value;
  final VoidCallback onToggle;

  const RememberCheckbox({
    super.key,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Semantics(
      checked: value,
      label: 'Keep me signed in',
      child: AfPressable(
        onTap: onToggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: afDuration(context, 160),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? tokens.ink : tokens.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: value ? tokens.ink : tokens.line),
                ),
                child: AnimatedOpacity(
                  opacity: value ? 1 : 0,
                  duration: afDuration(context, 150),
                  child: AnimatedScale(
                    scale: value ? 1 : 0.5,
                    duration: afDuration(context, 200),
                    curve: AutoFlowTokens.easeOut,
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: tokens.card,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ExcludeSemantics(
                child: Text(
                  'Keep me signed in',
                  style: AutoFlowTokens.caption.copyWith(color: tokens.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
