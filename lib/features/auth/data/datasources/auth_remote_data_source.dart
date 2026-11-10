import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  const AuthRemoteDataSource(this._dio);

  Future<AuthSessionModel> login(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.loginPath,
        data: {'email': email, 'password': password},
        options: Options(extra: {kSkipAuth: true}),
      );
      return AuthSessionModel.fromResponse(response.data ?? const {});
    } on DioException catch (e) {
      final mapped = mapDioException(e);
      // Wrong credentials are an auth failure, not an expired session.
      if (mapped is UnauthorizedException) {
        throw AuthException(message: mapped.message);
      }
      throw mapped;
    } on TypeError {
      throw const ServerException(message: 'Unexpected server response.');
    } on FormatException {
      throw const ServerException(message: 'Unexpected server response.');
    }
  }
}
