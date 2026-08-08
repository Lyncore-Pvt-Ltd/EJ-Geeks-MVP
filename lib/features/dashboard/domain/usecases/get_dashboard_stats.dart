import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStats implements UseCase<DashboardStats, void> {
  final DashboardRepository _repository;

  GetDashboardStats(this._repository);

  @override
  Future<Either<Failure, DashboardStats>> call(void params) {
    return _repository.getDashboardStats();
  }
}
