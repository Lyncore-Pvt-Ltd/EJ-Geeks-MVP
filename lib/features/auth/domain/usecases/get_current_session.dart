import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSession implements UseCase<AuthSession?, void> {
  final AuthRepository _repository;
  const GetCurrentSession(this._repository);

  @override
  Future<Either<Failure, AuthSession?>> call(void params) =>
      _repository.getCurrentSession();
}
