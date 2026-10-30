import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final rule = Expanded(child: Container(height: 1, color: tokens.line));
    return Row(
      children: [
        rule,
        const SizedBox(width: 12),
        Text('or', style: AutoFlowTokens.caption.copyWith(color: tokens.mute)),
        const SizedBox(width: 12),
        rule,
      ],
    );
  }
}
