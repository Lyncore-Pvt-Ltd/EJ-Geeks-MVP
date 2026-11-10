import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_session.dart';

/// App-wide holder of the signed-in [AuthSession]; the single read point for
/// role/permission-based UI.
class SessionController extends ChangeNotifier {
  AuthSession? _session;

  SessionController([this._session]);

  AuthSession? get session => _session;
  bool get isSignedIn => _session != null;

  bool can(String permission) => _session?.can(permission) ?? false;

  void setSession(AuthSession? session) {
    if (_session == session) return;
    _session = session;
    notifyListeners();
  }

  void clear() => setSession(null);
}
