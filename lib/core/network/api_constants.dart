import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Backend configuration. The base URL comes from `.env` (`API_BASE_URL`),
/// see `.env.example`.
class ApiConstants {
  const ApiConstants._();

  static const loginPath = '/v1/auth/login';
  static const refreshPath = '/v1/auth/refresh';

  static String get baseUrl {
    final url = dotenv.maybeGet('API_BASE_URL')?.trim() ?? '';
    if (url.isEmpty) {
      throw StateError(
        'API_BASE_URL is missing. Copy .env.example to .env and set it.',
      );
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
