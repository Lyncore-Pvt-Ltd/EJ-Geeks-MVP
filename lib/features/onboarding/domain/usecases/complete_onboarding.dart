import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboarding implements UseCase<void, void> {
  final OnboardingRepository _repository;

  CompleteOnboarding(this._repository);

  @override
  Future<Either<Failure, void>> call(void params) {
    return _repository.completeOnboarding();
  }
}
