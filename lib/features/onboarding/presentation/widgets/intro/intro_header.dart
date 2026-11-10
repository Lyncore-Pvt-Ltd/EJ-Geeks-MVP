import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../common/af_logo_mark.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';

class IntroHeader extends StatelessWidget {
  final VoidCallback onSkip;

  const IntroHeader({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return SizedBox(
      height: 48,
      child: Padding(
        // 16px screen gutter; Skip's own 16px padding sits inside the 8 on the right.
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          children: [
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AfWordmark(),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'Skip',
              onTap: onSkip,
              excludeSemantics: true,
              child: AfPressable(
                onTap: onSkip,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(
                    'Skip',
                    style: AutoFlowTokens.body.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: tokens.mute2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
