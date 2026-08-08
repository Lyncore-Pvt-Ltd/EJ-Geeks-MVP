import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class GetPendingPaymentDates implements UseCase<List<DateTime>, void> {
  final DashboardRepository _repository;

  GetPendingPaymentDates(this._repository);

  @override
  Future<Either<Failure, List<DateTime>>> call(void params) {
    return _repository.getPendingPaymentDates();
  }
}
