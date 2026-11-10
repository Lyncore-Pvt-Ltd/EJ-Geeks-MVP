import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/exceptions.dart';

/// Holds the access/refresh tokens. The access token is also cached in memory
/// so requests don't hit the keystore each time. When [persist] is false
/// (user unticked "Remember me") tokens live in memory only.
class TokenStorage {
  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  final FlutterSecureStorage _storage;
  String? _access;
  String? _refresh;
  bool _loaded = false;

  TokenStorage(this._storage);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      _access = await _storage.read(key: _accessKey);
      _refresh = await _storage.read(key: _refreshKey);
    } catch (e) {
      throw CacheException(message: 'Could not read secure storage: $e');
    }
    _loaded = true;
  }

  Future<String?> get accessToken async {
    await _ensureLoaded();
    return _access;
  }

  Future<String?> get refreshToken async {
    await _ensureLoaded();
    return _refresh;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    bool persist = true,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
    _loaded = true;
    try {
      if (persist) {
        await _storage.write(key: _accessKey, value: accessToken);
        await _storage.write(key: _refreshKey, value: refreshToken);
      } else {
        await _storage.delete(key: _accessKey);
        await _storage.delete(key: _refreshKey);
      }
    } catch (e) {
      throw CacheException(message: 'Could not write secure storage: $e');
    }
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _loaded = true;
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (e) {
      throw CacheException(message: 'Could not clear secure storage: $e');
    }
  }
}
