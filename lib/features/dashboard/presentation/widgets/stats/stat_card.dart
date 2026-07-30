import 'package:ej_geek/core/theme/app_pallete.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositiveTrend = trendPercent >= 0;
    final trendColor = isPositiveTrend
        ? AppPallete.emeraldTeal
        : AppPallete.errorColor;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              Row(
                children: [
                  Icon(
                    isPositiveTrend ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: trendColor,
                  ),
                  Text(
                    '${trendPercent.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppPallete.cascadingWhite
                      : AppPallete.tricornBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppPallete.boatAnchor : AppPallete.hypnotic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
