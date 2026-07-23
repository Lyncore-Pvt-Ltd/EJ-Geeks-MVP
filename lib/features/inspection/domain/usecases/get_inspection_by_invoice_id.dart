import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inspection_record.dart';
import '../repositories/inspection_repository.dart';

class GetInspectionByInvoiceId implements UseCase<InspectionRecord?, String> {
  final InspectionRepository _repository;

  GetInspectionByInvoiceId(this._repository);

  @override
  Future<Either<Failure, InspectionRecord?>> call(String params) {
    return _repository.getInspectionByInvoiceId(params);
  }
}
