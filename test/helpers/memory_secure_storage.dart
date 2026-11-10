import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// In-memory stand-in for the keystore so tests never hit platform channels.
class MemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> data = {};
  @override
  Future<String?> read({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async => data[key];
  @override
  Future<void> write({
    required String key,
    required String? value,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    if (value != null) data[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async => data.remove(key);
}
