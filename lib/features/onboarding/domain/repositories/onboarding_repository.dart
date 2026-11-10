import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, bool>> isOnboardingCompleted();
  Future<Either<Failure, void>> completeOnboarding();
}
