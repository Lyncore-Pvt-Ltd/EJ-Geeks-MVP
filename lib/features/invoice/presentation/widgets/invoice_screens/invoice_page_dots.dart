import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

class InvoicePageDots extends StatelessWidget {
  const InvoicePageDots({
    super.key,
    required this.controller,
    required this.count,
  });

  final PageController controller;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final duration = afDuration(context, 300);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.hasClients && controller.page != null
            ? controller.page!.round()
            : 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final isActive = index == page;
            return AnimatedContainer(
              duration: duration,
              curve: AutoFlowTokens.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AutoFlowTokens.accent : tokens.line,
                borderRadius: AfRadius.chipAll,
              ),
            );
          }),
        );
      },
    );
  }
}
