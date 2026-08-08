import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/monthly_revenue.dart';
import '../repositories/dashboard_repository.dart';

class GetMonthlyRevenue implements UseCase<List<MonthlyRevenue>, void> {
  final DashboardRepository _repository;

  GetMonthlyRevenue(this._repository);

  @override
  Future<Either<Failure, List<MonthlyRevenue>>> call(void params) {
    return _repository.getMonthlyRevenue();
  }
}
