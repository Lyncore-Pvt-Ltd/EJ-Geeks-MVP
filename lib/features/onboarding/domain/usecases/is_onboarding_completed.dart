import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

class IsOnboardingCompleted implements UseCase<bool, void> {
  final OnboardingRepository _repository;

  IsOnboardingCompleted(this._repository);

  @override
  Future<Either<Failure, bool>> call(void params) {
    return _repository.isOnboardingCompleted();
  }
}
