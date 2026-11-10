import 'dart:convert';

import 'package:auto_flow/core/network/auth_interceptor.dart';
import 'package:auto_flow/core/network/session_expiry.dart';
import 'package:auto_flow/core/network/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/memory_secure_storage.dart';

/// Scripted server: `/data` needs `Bearer new`; `/v1/auth/refresh` rotates.
class _Adapter implements HttpClientAdapter {
  int refreshCalls = 0;
  bool refreshOk = true;
  final seenAuth = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? body,
    Future<void>? cancel,
  ) async {
    ResponseBody json(int code, Object b) => ResponseBody.fromString(
      jsonEncode(b),
      code,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
    if (o.path.endsWith('/v1/auth/refresh')) {
      refreshCalls++;
      return refreshOk
          ? json(200, {
              'data': {'access_token': 'new', 'refresh_token': 'ref2'},
            })
          : json(401, {'message': 'bad refresh'});
    }
    final auth = o.headers['Authorization'] as String?;
    seenAuth.add(auth);
    return auth == 'Bearer new'
        ? json(200, {'ok': true})
        : json(401, {'message': 'expired'});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Adapter adapter;
  late TokenStorage tokens;
  late SessionExpiry expiry;
  late Dio dio;

  setUp(() async {
    adapter = _Adapter();
    tokens = TokenStorage(MemorySecureStorage());
    await tokens.saveTokens(accessToken: 'old', refreshToken: 'ref');
    expiry = SessionExpiry();
    dio = Dio(BaseOptions(baseUrl: 'http://t.local'))
      ..httpClientAdapter = adapter;
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://t.local'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        refreshDio: refreshDio,
        tokens: tokens,
        expiry: expiry,
      ),
    );
  });

  test('attaches the bearer token', () async {
    await tokens.saveTokens(accessToken: 'new', refreshToken: 'ref');
    await dio.get<dynamic>('/data');
    expect(adapter.seenAuth.single, 'Bearer new');
  });

  test('401 refreshes once, stores rotated tokens, replays request', () async {
    final res = await dio.get<dynamic>('/data');
    expect(res.statusCode, 200);
    expect(adapter.refreshCalls, 1);
    expect(await tokens.accessToken, 'new');
    expect(await tokens.refreshToken, 'ref2');
  });

  test('concurrent 401s trigger a single refresh', () async {
    await Future.wait([
      dio.get<dynamic>('/data'),
      dio.get<dynamic>('/data'),
      dio.get<dynamic>('/data'),
    ]);
    expect(adapter.refreshCalls, 1);
  });

  test('failed refresh clears tokens and signals session expiry', () async {
    adapter.refreshOk = false;
    var expired = 0;
    expiry.stream.listen((_) => expired++);
    await expectLater(dio.get<dynamic>('/data'), throwsA(isA<DioException>()));
    await Future<void>.delayed(Duration.zero);
    expect(expired, 1);
    expect(await tokens.refreshToken, isNull);
  });
}
