import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';

/// 8px page dots; the active one stretches to 24px. Each dot sits in a 44×44
/// tap target.
class AfPageDots extends StatelessWidget {
  final int count;
  final int index;
  final ValueChanged<int> onSelected;

  const AfPageDots({
    super.key,
    required this.count,
    required this.index,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Semantics(
            button: true,
            selected: i == index,
            label: 'Go to slide ${i + 1}',
            onTap: () => onSelected(i),
            excludeSemantics: true,
            // No press scale: the dot stretching is the feedback.
            child: AfPressable(
              pressedScale: 1,
              focusRadius: AfRadius.chipAll,
              onTap: () => onSelected(i),
              child: Container(
                height: 44,
                constraints: const BoxConstraints(minWidth: 44),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: afDuration(context, 300),
                  curve: AutoFlowTokens.easeOut,
                  width: i == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == index ? AutoFlowTokens.accent : tokens.line,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
