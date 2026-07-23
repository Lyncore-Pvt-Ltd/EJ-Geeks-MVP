import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inspection_record.dart';
import '../repositories/inspection_repository.dart';

class SaveInspection implements UseCase<void, InspectionRecord> {
  final InspectionRepository _repository;

  SaveInspection(this._repository);

  @override
  Future<Either<Failure, void>> call(InspectionRecord params) {
    return _repository.saveInspection(params);
  }
}
