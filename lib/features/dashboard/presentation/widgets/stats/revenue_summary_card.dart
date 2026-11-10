import 'package:auto_flow/core/presentation/widgets/af/af_animated_number.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/dashboard/domain/entities/daily_revenue.dart';
import 'package:auto_flow/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:auto_flow/features/dashboard/presentation/widgets/common/dashboard_card.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TotalRevenueCard extends StatelessWidget {
  const TotalRevenueCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();

    return _SummaryPanel(
      title: 'Total Revenue',
      amount: dashboard.stats.totalRevenue,
      headerIcon: Icons.trending_up_rounded,
      chartLabel: 'Daily revenue this month, today highlighted',
      chart: _RevenueBars(dailyRevenue: dashboard.dailyRevenue),
    );
  }
}

class PendingPaymentsCard extends StatelessWidget {
  const PendingPaymentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();

    return _SummaryPanel(
      title: 'Pending Payments',
      amount: dashboard.stats.pendingAmount,
      headerIcon: Icons.access_time_rounded,
      chartLabel:
          '${dashboard.pendingPaymentDates.length} days this month with '
          'pending payments',
      chart: _PendingDots(pendingDates: dashboard.pendingPaymentDates),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  static const double height = 170;

  final String title;
  final double amount;
  final Widget chart;
  final String chartLabel;
  final IconData headerIcon;

  const _SummaryPanel({
    required this.title,
    required this.amount,
    required this.chart,
    required this.chartLabel,
    required this.headerIcon,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    return DashboardCard(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: DashboardEyebrow(title)),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tokens.hot,
                  borderRadius: AfRadius.smallAll,
                ),
                child: ExcludeSemantics(
                  child: Icon(
                    headerIcon,
                    size: 16,
                    color: AutoFlowTokens.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AfSpace.xs4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AfAnimatedNumber(
              value: amount,
              formatter: formatAud,
              semanticsPrefix: title,
              style: AutoFlowTokens.mono(fontSize: 22, color: tokens.ink),
            ),
          ),
          const SizedBox(height: AfSpace.s12),
          Expanded(
            child: Semantics(
              label: chartLabel,
              excludeSemantics: true,
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueBars extends StatelessWidget {
  final List<DailyRevenue> dailyRevenue;

  const _RevenueBars({required this.dailyRevenue});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
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
                        ? AutoFlowTokens.accent
                        : tokens.navy,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
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

  const _PendingDots({required this.pendingDates});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Wrap(
        spacing: AfSpace.xs4,
        runSpacing: AfSpace.xs4,
        children: [
          for (var day = 1; day <= daysInMonth; day++)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pendingDates.contains(DateTime(now.year, now.month, day))
                    ? AutoFlowTokens.accent
                    : tokens.line,
              ),
            ),
        ],
      ),
    );
  }
}
