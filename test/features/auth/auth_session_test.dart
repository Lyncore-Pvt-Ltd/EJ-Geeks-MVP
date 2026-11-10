import 'package:auto_flow/features/auth/data/models/auth_session_model.dart';
import 'package:auto_flow/features/auth/domain/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _payload({
  String? branchId,
  required List<String> perms,
}) => {
  'data': {
    'user': {
      'id': 'u',
      'email': 'a@b.lk',
      'full_name': 'A B',
      'created_at': '2026-11-09T12:46:32Z',
    },
    'roles': [
      {
        'branch_id': branchId,
        'role_id': 'r',
        'role_name': branchId == null ? 'Super Admin' : 'Branch Manager',
        'role_permissions': perms,
      },
    ],
    'access_token': 'acc',
    'refresh_token': 'ref',
  },
};

void main() {
  test('Branch Manager: branch scoped, can generate PDFs, no roles', () {
    final m = AuthSessionModel.fromResponse(
      _payload(branchId: 'b1', perms: ['invoice:read', 'pdf:generate']),
    );
    expect(m.accessToken, 'acc');
    expect(m.refreshToken, 'ref');
    expect(m.session.isBranchScoped, isTrue);
    expect(m.session.can(Permissions.pdfGenerate), isTrue);
    expect(m.session.can(Permissions.rolesRead), isFalse);
  });

  test('Super Admin: null branch, manages roles, no pdf:generate', () {
    final m = AuthSessionModel.fromResponse(
      _payload(perms: ['roles:read', 'invoice:read']),
    );
    expect(m.session.isBranchScoped, isFalse);
    expect(m.session.can(Permissions.rolesRead), isTrue);
    expect(m.session.can(Permissions.pdfGenerate), isFalse);
  });

  test('session survives a JSON round trip', () {
    final s = AuthSessionModel.fromResponse(
      _payload(branchId: 'b1', perms: ['invoice:read']),
    ).session;
    final back = AuthSessionModel.sessionFromJson(
      AuthSessionModel.sessionToJson(s),
    );
    expect(back, s);
  });
}
