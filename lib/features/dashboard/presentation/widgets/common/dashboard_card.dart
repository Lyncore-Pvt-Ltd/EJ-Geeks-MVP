import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

/// The DESIGN.md card surface shared by every dashboard tile: card fill,
/// 1px line border, 16px radius and the navy-tinted card shadow.
class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AfSpace.m16),
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AfRadius.cardAll,
        border: Border.all(color: tokens.line),
        boxShadow: AutoFlowTokens.cardShadow,
      ),
      child: child,
    );
  }
}

/// Uppercase 11px eyebrow label used as a card heading.
class DashboardEyebrow extends StatelessWidget {
  final String text;

  const DashboardEyebrow(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AutoFlowTokens.caption.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: AutoFlowTokens.of(context).mute,
      ),
    );
  }
}
