import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/dashboard/domain/entities/daily_revenue.dart';
import 'package:ej_geek/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TotalRevenueCard extends StatelessWidget {
  const TotalRevenueCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboard = context.watch<DashboardProvider>();

    return _SummaryPanel(
      isDark: isDark,
      title: 'Total Revenue',
      value: dashboard.revenueLabel,
      headerIcon: Icons.trending_up,
      headerIconColor: AppPallete.emeraldTeal,
      chart: _RevenueBars(
        dailyRevenue: dashboard.dailyRevenue,
        isDark: isDark,
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
      headerIcon: Icons.access_time_rounded,
      headerIconColor: AppPallete.amberOrange,
      headerIconOutlined: true,
      chart: _PendingDots(
        pendingDates: dashboard.pendingPaymentDates,
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
  final IconData headerIcon;
  final Color headerIconColor;
  final bool headerIconOutlined;

  const _SummaryPanel({
    required this.isDark,
    required this.title,
    required this.value,
    required this.chart,
    required this.headerIcon,
    required this.headerIconColor,
    this.headerIconOutlined = false,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: titleColor,
                ),
              ),
              headerIconOutlined
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: headerIconColor, width: 1.5),
                      ),
                      child: Icon(headerIcon, size: 12, color: headerIconColor),
                    )
                  : Icon(headerIcon, size: 20, color: headerIconColor),
            ],
          ),
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
  final List<DailyRevenue> dailyRevenue;
  final bool isDark;

  const _RevenueBars({required this.dailyRevenue, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final maxRevenue = dailyRevenue.isEmpty
        ? 0.0
        : dailyRevenue.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
    final now = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < dailyRevenue.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height: maxRevenue == 0
                      ? 0
                      : constraints.maxHeight *
                            (dailyRevenue[i].revenue / maxRevenue),
                  decoration: BoxDecoration(
                    color: DateUtils.isSameDay(dailyRevenue[i].date, now)
                        ? AppPallete.selectionGradient[1]
                        : (isDark ? Colors.white : Colors.black),
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
  final Set<DateTime> pendingDates;
  final Color mutedColor;

  const _PendingDots({required this.pendingDates, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (var day = 1; day <= daysInMonth; day++)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    pendingDates.contains(DateTime(now.year, now.month, day))
                    ? AppPallete.selectionGradient[1]
                    : mutedColor.withValues(alpha: 0.25),
              ),
            ),
        ],
      ),
    );
  }
}
