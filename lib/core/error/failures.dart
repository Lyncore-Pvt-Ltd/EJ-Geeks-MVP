import 'package:equatable/equatable.dart';

//Base class
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

//Concrete failure types

/// Returned when the backend API responds with a non-2xx status code.
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Returned when a network / connectivity error prevents the request.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Returned when the OIDC login, logout, or token-refresh flow fails.
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Returned when reading or writing to secure storage / the local database fails.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Returned when the server responds 401 and a refresh is not possible.
/// The presentation layer should react by navigating back to the login page.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}

/// Returned when writing/copying a file (image, PDF) to local storage fails.
class StorageFailure extends Failure {
  const StorageFailure({required super.message});
}
