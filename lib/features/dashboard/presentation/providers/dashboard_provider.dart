import 'package:ej_geek/core/di/service_locator.dart';
import 'package:ej_geek/features/dashboard/domain/entities/daily_revenue.dart';
import 'package:ej_geek/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:ej_geek/features/dashboard/domain/entities/monthly_revenue.dart';
import 'package:ej_geek/features/dashboard/domain/usecases/get_daily_revenue.dart';
import 'package:ej_geek/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:ej_geek/features/dashboard/domain/usecases/get_monthly_revenue.dart';
import 'package:ej_geek/features/dashboard/domain/usecases/get_pending_payment_dates.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:flutter/foundation.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    GetDashboardStats? getDashboardStats,
    GetDailyRevenue? getDailyRevenue,
    GetPendingPaymentDates? getPendingPaymentDates,
    GetMonthlyRevenue? getMonthlyRevenue,
  }) : _getDashboardStats = getDashboardStats ?? sl(),
       _getDailyRevenue = getDailyRevenue ?? sl(),
       _getPendingPaymentDates = getPendingPaymentDates ?? sl(),
       _getMonthlyRevenue = getMonthlyRevenue ?? sl() {
    _loadDashboardData();
  }

  final GetDashboardStats _getDashboardStats;
  final GetDailyRevenue _getDailyRevenue;
  final GetPendingPaymentDates _getPendingPaymentDates;
  final GetMonthlyRevenue _getMonthlyRevenue;

  DashboardStats stats = const DashboardStats();
  List<DailyRevenue> dailyRevenue = [];
  Set<DateTime> pendingPaymentDates = {};
  List<MonthlyRevenue> monthlyRevenue = [];

  // Runs once on construction, and again on demand via [refresh]; all four
  // usecases run as concurrent, lean SQL aggregate queries (see
  // DashboardLocalDataSource) rather than on every rebuild.
  Future<void> _loadDashboardData() async {
    await Future.wait([
      _getDashboardStats(null).then(
        (result) => result.fold(
          (failure) => debugPrint(
            'DashboardProvider: dashboard stats failed: ${failure.message}',
          ),
          (data) => stats = data,
        ),
      ),
      _getDailyRevenue(null).then(
        (result) => result.fold(
          (failure) => debugPrint(
            'DashboardProvider: daily revenue failed: ${failure.message}',
          ),
          (data) => dailyRevenue = data,
        ),
      ),
      _getPendingPaymentDates(null).then(
        (result) => result.fold(
          (failure) => debugPrint(
            'DashboardProvider: pending payment dates failed: ${failure.message}',
          ),
          (data) => pendingPaymentDates = data.toSet(),
        ),
      ),
      _getMonthlyRevenue(null).then(
        (result) => result.fold(
          (failure) => debugPrint(
            'DashboardProvider: monthly revenue failed: ${failure.message}',
          ),
          (data) => monthlyRevenue = data,
        ),
      ),
    ]);
    notifyListeners();
  }

  Future<void> refresh() => _loadDashboardData();

  String get revenueLabel => formatAud(stats.totalRevenue);
  String get revenueChangeLabel =>
      '${trimmedAmount(stats.revenueChangePercent)}% than last month';
  String get pendingAmountLabel => formatAud(stats.pendingAmount);
  int get invoiceCount => stats.invoiceCount;
  int get pendingCount => stats.pendingCount;
  int get paidCount => stats.paidCount;
  double get invoiceTrend => stats.invoiceTrendPercent;
  double get pendingTrend => stats.pendingTrendPercent;
  double get paidTrend => stats.paidTrendPercent;
}
