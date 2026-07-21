import 'package:ej_geek/core/constants/dashboard_dummy_data.dart';
import 'package:flutter/foundation.dart';

class DashboardProvider extends ChangeNotifier {
  final int invoiceCount = dummyInvoiceCount;
  final int pendingCount = dummyPendingCount;
  final int paidCount = dummyPaidCount;
  final String revenueLabel = dummyRevenueLabel;
  final String revenueChangeLabel = dummyRevenueChangeLabel;
  final String pendingAmountLabel = dummyPendingAmountLabel;
  final List<MonthlyRevenue> monthlyRevenue = dummyMonthlyRevenue;
}
