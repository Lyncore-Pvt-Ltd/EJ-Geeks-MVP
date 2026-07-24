/// Thrown when the remote API returns an error response.
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
  @override
  String toString() => 'ServerException: $message';
}

/// Thrown when a network / socket problem prevents a request.
class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});
  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the OIDC flow (login / logout / refresh) fails.
class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
  @override
  String toString() => 'AuthException: $message';
}

/// Thrown when secure storage / local database read/write fails.
class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
  @override
  String toString() => 'CacheException: $message';
}

/// Thrown on HTTP 401 when the token cannot be refreshed.
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({required this.message});
  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Thrown when writing/copying a file (image, PDF) to local storage fails.
class StorageException implements Exception {
  final String message;
  const StorageException({required this.message});
  @override
  String toString() => 'StorageException: $message';
}
