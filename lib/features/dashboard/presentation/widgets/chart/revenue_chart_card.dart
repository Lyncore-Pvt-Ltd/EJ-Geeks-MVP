import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:auto_flow/features/dashboard/presentation/widgets/common/dashboard_card.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final monthlyRevenue = context.watch<DashboardProvider>().monthlyRevenue;

    final axisStyle = AutoFlowTokens.mono(fontSize: 10, color: tokens.mute);

    final maxRevenue = monthlyRevenue.isEmpty
        ? 0.0
        : monthlyRevenue.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(
        AfSpace.m16,
        AfSpace.m16,
        AfSpace.l24,
        AfSpace.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue by month',
            style: AutoFlowTokens.title.copyWith(color: tokens.ink),
          ),
          const SizedBox(height: AfSpace.m16),
          SizedBox(
            height: 200,
            child: Semantics(
              label: monthlyRevenue.isEmpty
                  ? 'Revenue by month: no data'
                  : 'Revenue by month: ${[for (final m in monthlyRevenue) '${m.month} ${formatAud(m.revenue)}'].join(', ')}',
              excludeSemantics: true,
              child: LineChart(
                duration: afDuration(context, 250),
                curve: AutoFlowTokens.easeOut,
                LineChartData(
                  minY: 0,
                  maxY: maxRevenue == 0 ? 1 : maxRevenue * 1.2,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: tokens.line, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(bottom: BorderSide(color: tokens.line)),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AutoFlowTokens.navyInk,
                      tooltipBorderRadius: AfRadius.smallAll,
                      getTooltipItems: (spots) => [
                        for (final spot in spots)
                          LineTooltipItem(
                            formatAud(spot.y),
                            AutoFlowTokens.mono(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    getTouchedSpotIndicator: (bar, indexes) => [
                      for (final _ in indexes)
                        TouchedSpotIndicatorData(
                          FlLine(color: tokens.mute, strokeWidth: 1),
                          FlDotData(
                            getDotPainter: (spot, percent, bar, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: AutoFlowTokens.accent,
                                  strokeWidth: 2,
                                  strokeColor: tokens.card,
                                ),
                          ),
                        ),
                    ],
                  ),
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
                          style: axisStyle,
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
                              style: axisStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: AutoFlowTokens.accent,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AutoFlowTokens.accent.withValues(alpha: 0.24),
                            AutoFlowTokens.accent.withValues(alpha: 0.0),
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
          ),
        ],
      ),
    );
  }
}
