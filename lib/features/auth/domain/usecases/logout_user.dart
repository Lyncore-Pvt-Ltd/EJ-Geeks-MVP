import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUser implements UseCase<void, void> {
  final AuthRepository _repository;
  const LogoutUser(this._repository);

  @override
  Future<Either<Failure, void>> call(void params) => _repository.logout();
}
