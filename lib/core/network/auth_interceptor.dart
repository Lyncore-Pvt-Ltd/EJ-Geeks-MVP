import 'dart:async';

import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'session_expiry.dart';
import 'token_storage.dart';

/// Marks a request as public (login / refresh): no bearer token attached and
/// no refresh attempted on 401.
const kSkipAuth = 'skipAuth';
const _kRetried = 'authRetried';

/// Attaches `Authorization: Bearer <access>` to every request and, on a 401,
/// refreshes the tokens once (single-flight) and replays the request.
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokens;
  final SessionExpiry _expiry;

  /// [refreshDio] must be a bare client (no interceptors) to avoid recursion.
  AuthInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required TokenStorage tokens,
    required SessionExpiry expiry,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _tokens = tokens,
       _expiry = expiry;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[kSkipAuth] != true) {
      final token = await _tokens.accessToken;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final eligible =
        err.response?.statusCode == 401 &&
        request.extra[kSkipAuth] != true &&
        request.extra[_kRetried] != true;
    if (!eligible) return handler.next(err);

    // QueuedInterceptor serialises errors, so if an earlier request already
    // refreshed, the stored token differs from the one this request sent.
    final sent = request.headers['Authorization'];
    final current = await _tokens.accessToken;
    if (current != null && sent != 'Bearer $current') {
      return _retry(request, handler, err);
    }

    final refreshed = await _refresh();
    if (!refreshed) {
      await _tokens.clear();
      _expiry.notify();
      return handler.next(err);
    }
    return _retry(request, handler, err);
  }

  Future<bool> _refresh() async {
    final refreshToken = await _tokens.refreshToken;
    if (refreshToken == null) return false;
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refreshPath,
        data: {'refresh_token': refreshToken},
        options: Options(extra: {kSkipAuth: true}),
      );
      final body = response.data;
      final data = body?['data'] is Map ? body!['data'] as Map : body;
      final access = data?['access_token'];
      final refresh = data?['refresh_token'];
      if (access is! String || refresh is! String) return false;
      await _tokens.saveTokens(accessToken: access, refreshToken: refresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _retry(
    RequestOptions request,
    ErrorInterceptorHandler handler,
    DioException original,
  ) async {
    try {
      final token = await _tokens.accessToken;
      request.headers['Authorization'] = 'Bearer $token';
      request.extra[_kRetried] = true;
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(original);
    }
  }
}
