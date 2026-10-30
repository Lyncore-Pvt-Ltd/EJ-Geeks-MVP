import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../common/af_logo_mark.dart';
import '../common/af_motion.dart';

class IntroHeader extends StatelessWidget {
  final VoidCallback onSkip;

  const IntroHeader({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 8),
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
