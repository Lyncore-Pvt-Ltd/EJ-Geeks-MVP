import 'package:ej_geek/core/constants/dashboard_dummy_data.dart';
import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TotalRevenueCard extends StatelessWidget {
  const TotalRevenueCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboard = context.watch<DashboardProvider>();
    final titleColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;

    return _SummaryPanel(
      isDark: isDark,
      title: 'Total Revenue',
      value: dashboard.revenueLabel,
      chart: _RevenueBars(
        monthlyRevenue: dashboard.monthlyRevenue,
        mutedColor: titleColor,
      ),
    );
  }
}

class PendingPaymentsCard extends StatelessWidget {
  const PendingPaymentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboard = context.watch<DashboardProvider>();
    final titleColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;

    return _SummaryPanel(
      isDark: isDark,
      title: 'Pending Payments',
      value: dashboard.pendingAmountLabel,
      chart: _PendingDots(
        pendingCount: dashboard.pendingCount,
        mutedColor: titleColor,
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  static const double height = 170;

  final bool isDark;
  final String title;
  final String value;
  final Widget chart;

  const _SummaryPanel({
    required this.isDark,
    required this.title,
    required this.value,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;
    final valueColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;

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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: titleColor)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: chart),
        ],
      ),
    );
  }
}

class _RevenueBars extends StatelessWidget {
  final List<MonthlyRevenue> monthlyRevenue;
  final Color mutedColor;

  const _RevenueBars({required this.monthlyRevenue, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final bars = monthlyRevenue.length > 6
        ? monthlyRevenue.sublist(monthlyRevenue.length - 6)
        : monthlyRevenue;
    final maxRevenue = bars
        .map((e) => e.revenue)
        .reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < bars.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height:
                      constraints.maxHeight * (bars[i].revenue / maxRevenue),
                  decoration: BoxDecoration(
                    color: i == bars.length - 1
                        ? const Color(0xFFFF6060)
                        : mutedColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PendingDots extends StatelessWidget {
  final int pendingCount;
  final Color mutedColor;

  const _PendingDots({required this.pendingCount, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    const totalDots = 30;
    final highlightedDots = pendingCount.clamp(0, totalDots);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (var i = 0; i < totalDots; i++)
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < highlightedDots
                    ? const Color(0xFFFF6060)
                    : mutedColor.withValues(alpha: 0.25),
              ),
            ),
        ],
      ),
    );
  }
}
