import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/dashboard/presentation/widgets/common/dashboard_card.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  static const double height = 116;

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final double trendPercent;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.trendPercent,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final isPositiveTrend = trendPercent >= 0;
    final trendText = '${trendPercent.abs().toStringAsFixed(1)}%';

    return Semantics(
      container: true,
      label: '$label: $value, ${isPositiveTrend ? 'up' : 'down'} $trendText',
      excludeSemantics: true,
      child: DashboardCard(
        height: height,
        padding: const EdgeInsets.all(AfSpace.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // On narrow phones three tiles leave too little room for both the
            // icon tile and the trend chip; the trend (data) wins.
            LayoutBuilder(
              builder: (context, constraints) => Row(
                children: [
                  if (constraints.maxWidth >= 96)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: tokens.soft,
                        borderRadius: AfRadius.smallAll,
                      ),
                      child: Icon(icon, size: 16, color: accentColor),
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _TrendChip(
                        text: trendText,
                        isPositive: isPositiveTrend,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: AutoFlowTokens.mono(fontSize: 20, color: tokens.ink),
                  ),
                ),
                const SizedBox(height: AfSpace.xs4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AutoFlowTokens.caption.copyWith(color: tokens.mute),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final String text;
  final bool isPositive;

  const _TrendChip({required this.text, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final fg = isPositive ? AutoFlowTokens.successFg : AutoFlowTokens.errorFg;
    final bg = isPositive ? AutoFlowTokens.successBg : AutoFlowTokens.errorBg;
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: bg, borderRadius: AfRadius.chipAll),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 11,
              color: fg,
            ),
            Text(
              text,
              maxLines: 1,
              style: AutoFlowTokens.mono(fontSize: 11, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
