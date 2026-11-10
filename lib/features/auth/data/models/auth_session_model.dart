import '../../domain/entities/auth_session.dart';

/// Wire format for `/v1/auth/login` (`{"data": {user, roles, access_token,
/// refresh_token}}`). All JSON field names live here.
class AuthSessionModel {
  final AuthSession session;
  final String accessToken;
  final String refreshToken;

  const AuthSessionModel({
    required this.session,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthSessionModel.fromResponse(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing "data" in auth response');
    }
    return AuthSessionModel(
      session: sessionFromJson(data),
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  /// Parses `{user, roles}`; also used for the locally cached copy.
  static AuthSession sessionFromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final roles = (json['roles'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    return AuthSession(
      user: AuthUser(
        id: user['id'] as String,
        email: user['email'] as String,
        fullName: (user['full_name'] as String?) ?? '',
      ),
      roles: [
        for (final r in roles)
          UserRole(
            roleId: r['role_id'] as String,
            roleName: r['role_name'] as String,
            branchId: r['branch_id'] as String?,
            permissions: {
              for (final p in (r['role_permissions'] as List? ?? const []))
                p as String,
            },
          ),
      ],
    );
  }

  static Map<String, dynamic> sessionToJson(AuthSession s) => {
    'user': {
      'id': s.user.id,
      'email': s.user.email,
      'full_name': s.user.fullName,
    },
    'roles': [
      for (final r in s.roles)
        {
          'role_id': r.roleId,
          'role_name': r.roleName,
          'branch_id': r.branchId,
          'role_permissions': r.permissions.toList(),
        },
    ],
  };
}
