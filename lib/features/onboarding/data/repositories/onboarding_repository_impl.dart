import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  OnboardingRepositoryImpl({OnboardingLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? OnboardingLocalDataSource();

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() async {
    try {
      return Right(await _localDataSource.isOnboardingCompleted());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      await _localDataSource.completeOnboarding();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
