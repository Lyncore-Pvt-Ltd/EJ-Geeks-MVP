import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../models/auth_session_model.dart';

/// Persists tokens (via [TokenStorage]) and the user + roles, so a relaunch
/// restores the session and permissions without a network call.
class AuthLocalDataSource {
  static const _sessionKey = 'auth_session';

  final TokenStorage _tokens;
  final FlutterSecureStorage _storage;
  AuthSession? _memory;

  AuthLocalDataSource(this._tokens, this._storage);

  Future<void> save(AuthSessionModel model, {required bool remember}) async {
    await _tokens.saveTokens(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      persist: remember,
    );
    _memory = model.session;
    try {
      if (remember) {
        await _storage.write(
          key: _sessionKey,
          value: jsonEncode(AuthSessionModel.sessionToJson(model.session)),
        );
      } else {
        await _storage.delete(key: _sessionKey);
      }
    } catch (e) {
      throw CacheException(message: 'Could not save session: $e');
    }
  }

  /// Null when there is no stored refresh token or session.
  Future<AuthSession?> read() async {
    if (await _tokens.refreshToken == null) return null;
    if (_memory != null) return _memory;
    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null) return null;
      return _memory = AuthSessionModel.sessionFromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on CacheException {
      rethrow;
    } catch (_) {
      // Corrupt cache: treat as signed out.
      return null;
    }
  }

  /// Always attempts both deletes; in-memory tokens are dropped first so
  /// requests stop carrying them even if the keystore delete fails.
  Future<void> clear() async {
    _memory = null;
    Object? error;
    try {
      await _tokens.clear();
    } on CacheException catch (e) {
      error = e;
    }
    try {
      await _storage.delete(key: _sessionKey);
    } catch (e) {
      error ??= e;
    }
    if (error != null) {
      throw CacheException(message: 'Could not clear session: $error');
    }
  }
}
