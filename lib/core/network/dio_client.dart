import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_constants.dart';
import 'auth_interceptor.dart';
import 'session_expiry.dart';
import 'token_storage.dart';

/// Builds the app-wide [Dio]: base URL from `.env`, JSON, timeouts, bearer
/// token + refresh interceptor. Feature data sources use `sl<Dio>()`.
Dio buildDio({required TokenStorage tokens, required SessionExpiry expiry}) {
  BaseOptions options() => BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: const {'Accept': 'application/json'},
    contentType: Headers.jsonContentType,
  );

  final dio = Dio(options());
  final refreshDio = Dio(options());
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      refreshDio: refreshDio,
      tokens: tokens,
      expiry: expiry,
    ),
  );
  if (kDebugMode) {
    // Headers/bodies are not logged: they contain tokens and passwords.
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
  }
  return dio;
}
