import 'package:ej_geek/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:ej_geek/features/dashboard/presentation/widgets/chart/revenue_chart_card.dart';
import 'package:ej_geek/features/dashboard/presentation/widgets/stats/revenue_summary_card.dart';
import 'package:ej_geek/features/dashboard/presentation/widgets/stats/stat_card.dart';
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: TotalRevenueCard()),
                  const SizedBox(width: 12),
                  Expanded(child: PendingPaymentsCard()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Invoices',
                      value: '${dashboard.invoiceCount}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Pending',
                      value: '${dashboard.pendingCount}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Paid',
                      value: '${dashboard.paidCount}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const RevenueChartCard(),
            ],
          ),
        ),
      ),
    );
  }
}
