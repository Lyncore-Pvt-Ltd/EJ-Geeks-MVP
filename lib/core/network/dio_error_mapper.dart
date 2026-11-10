import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Turns a [DioException] into the app's typed exceptions.
Exception mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException(
        message: 'Cannot reach the server. Check your connection.',
      );
    default:
      break;
  }
  final status = e.response?.statusCode;
  final message = _serverMessage(e.response?.data);
  if (status == 401) {
    return UnauthorizedException(message: message ?? 'Invalid credentials.');
  }
  if (e.error is Exception && e.response == null) {
    return const NetworkException(message: 'Network error. Try again.');
  }
  return ServerException(message: message ?? 'Server error ($status).');
}

String? _serverMessage(Object? data) {
  if (data is Map) {
    final error = data['error'];
    final candidates = [
      data['message'],
      if (error is Map) error['message'] else error,
    ];
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c;
    }
  }
  return null;
}
