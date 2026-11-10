import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
    required bool remember,
  });

  /// The stored session, or null when signed out.
  Future<Either<Failure, AuthSession?>> getCurrentSession();

  Future<Either<Failure, void>> logout();

  /// Fires when the refresh token is rejected and the user must sign in again.
  Stream<void> get sessionExpired;
}
