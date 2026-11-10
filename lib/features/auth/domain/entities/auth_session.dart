import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String fullName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, email, fullName];
}

class UserRole extends Equatable {
  final String roleId;
  final String roleName;

  /// Null for global roles (Super Admin); set for branch-scoped ones.
  final String? branchId;
  final Set<String> permissions;

  const UserRole({
    required this.roleId,
    required this.roleName,
    required this.permissions,
    this.branchId,
  });

  @override
  List<Object?> get props => [roleId, roleName, branchId, permissions];
}

/// The signed-in user plus what they may do. Gate UI on [can], never on
/// role names.
class AuthSession extends Equatable {
  final AuthUser user;
  final List<UserRole> roles;

  const AuthSession({required this.user, required this.roles});

  Set<String> get permissions => {for (final r in roles) ...r.permissions};

  bool can(String permission) =>
      roles.any((r) => r.permissions.contains(permission));

  /// Branch the user is limited to, or null for global roles.
  String? get branchId {
    for (final r in roles) {
      if (r.branchId != null) return r.branchId;
    }
    return null;
  }

  bool get isBranchScoped => branchId != null;

  /// Display only, e.g. "Branch Manager".
  String get roleLabel => roles.map((r) => r.roleName).join(', ');

  @override
  List<Object?> get props => [user, roles];
}
