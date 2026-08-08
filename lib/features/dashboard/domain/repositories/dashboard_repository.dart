import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/daily_revenue.dart';
import '../entities/dashboard_stats.dart';
import '../entities/monthly_revenue.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();

  Future<Either<Failure, List<DailyRevenue>>> getDailyRevenue();

  Future<Either<Failure, List<DateTime>>> getPendingPaymentDates();

  Future<Either<Failure, List<MonthlyRevenue>>> getMonthlyRevenue();
}
