import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlyRevenue = context.watch<DashboardProvider>().monthlyRevenue;

    final textColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;
    final gridColor = isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite;

    final maxRevenue = monthlyRevenue
        .map((e) => e.revenue)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 12),
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
        children: [
          Text(
            'Revenue by Month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppPallete.cascadingWhite
                  : AppPallete.tricornBlack,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxRevenue * 1.2,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: gridColor, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value / 1000).round()}k',
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyRevenue.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            monthlyRevenue[index].month,
                            style: TextStyle(fontSize: 10, color: textColor),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF3D3D),
                        Color(0xFFFF6060),
                        Color(0xFFFF8A80),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFF6060).withValues(alpha: 0.3),
                          const Color(0xFFFF6060).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    spots: [
                      for (var i = 0; i < monthlyRevenue.length; i++)
                        FlSpot(i.toDouble(), monthlyRevenue[i].revenue),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
