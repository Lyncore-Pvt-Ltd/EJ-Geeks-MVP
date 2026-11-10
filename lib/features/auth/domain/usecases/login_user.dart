import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  final bool remember;

  const LoginParams({
    required this.email,
    required this.password,
    this.remember = true,
  });

  @override
  List<Object?> get props => [email, password, remember];
}

class LoginUser implements UseCase<AuthSession, LoginParams> {
  final AuthRepository _repository;
  const LoginUser(this._repository);

  @override
  Future<Either<Failure, AuthSession>> call(LoginParams params) =>
      _repository.login(
        email: params.email,
        password: params.password,
        remember: params.remember,
      );
}
