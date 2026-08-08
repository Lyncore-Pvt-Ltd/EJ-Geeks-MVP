import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_revenue.dart';
import '../repositories/dashboard_repository.dart';

class GetDailyRevenue implements UseCase<List<DailyRevenue>, void> {
  final DashboardRepository _repository;

  GetDailyRevenue(this._repository);

  @override
  Future<Either<Failure, List<DailyRevenue>>> call(void params) {
    return _repository.getDailyRevenue();
  }
}
