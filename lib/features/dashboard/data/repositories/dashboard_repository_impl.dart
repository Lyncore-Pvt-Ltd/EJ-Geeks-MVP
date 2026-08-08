import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/daily_revenue.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/monthly_revenue.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource _localDataSource;

  DashboardRepositoryImpl({DashboardLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? DashboardLocalDataSource();

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final stats = await _localDataSource.getDashboardStats();
      return Right(stats);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<DailyRevenue>>> getDailyRevenue() async {
    try {
      final revenue = await _localDataSource.getDailyRevenue();
      return Right(revenue);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getPendingPaymentDates() async {
    try {
      final dates = await _localDataSource.getPendingPaymentDates();
      return Right(dates);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<MonthlyRevenue>>> getMonthlyRevenue() async {
    try {
      final revenue = await _localDataSource.getMonthlyRevenue();
      return Right(revenue);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
