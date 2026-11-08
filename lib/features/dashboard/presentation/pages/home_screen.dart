import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:auto_flow/features/dashboard/presentation/widgets/chart/revenue_chart_card.dart';
import 'package:auto_flow/features/dashboard/presentation/widgets/stats/revenue_summary_card.dart';
import 'package:auto_flow/features/dashboard/presentation/widgets/stats/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final tokens = AutoFlowTokens.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().refresh(),
        color: AutoFlowTokens.accent,
        backgroundColor: tokens.card,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AfSpace.gutter,
              vertical: AfSpace.s8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Staggered entrance; plays once per mount (provider
                // rebuilds and pull-to-refresh don't replay it).
                const AfStaggerIn(index: 0, child: TotalRevenueCard()),
                const SizedBox(height: AfSpace.s12),
                const AfStaggerIn(index: 1, child: PendingPaymentsCard()),
                const SizedBox(height: AfSpace.sectionGap),
                AfStaggerIn(
                  index: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Invoices',
                          value: '${dashboard.invoiceCount}',
                          icon: Icons.receipt_long_rounded,
                          accentColor: tokens.ink,
                          trendPercent: dashboard.invoiceTrend,
                        ),
                      ),
                      const SizedBox(width: AfSpace.s12),
                      Expanded(
                        child: StatCard(
                          label: 'Pending',
                          value: '${dashboard.pendingCount}',
                          icon: Icons.pending_actions_rounded,
                          accentColor: AutoFlowTokens.accent,
                          trendPercent: dashboard.pendingTrend,
                        ),
                      ),
                      const SizedBox(width: AfSpace.s12),
                      Expanded(
                        child: StatCard(
                          label: 'Paid',
                          value: '${dashboard.paidCount}',
                          icon: Icons.check_circle_rounded,
                          accentColor: tokens.ink,
                          trendPercent: dashboard.paidTrend,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AfSpace.sectionGap),
                const AfStaggerIn(index: 3, child: RevenueChartCard()),
                SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
