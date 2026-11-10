import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/presentation/widget/confirm_dialog.dart';
import '../../../features/onboarding/presentation/pages/login_page.dart';
import '../../../main.dart' show rootNavigatorKey;
import '../domain/usecases/logout_user.dart';
import 'session/session_controller.dart';

/// Asks for confirmation, then signs out: discards the tokens and cached
/// session on the device (the backend has no logout endpoint) and returns to
/// Login. Signing out always completes locally, even if storage fails.
Future<void> confirmAndLogout(BuildContext context) async {
  final session = context.read<SessionController>();
  final confirmed = await showConfirmDialog(
    context,
    title: 'Log out?',
    message: 'You will need to sign in again to use AutoFlow.',
    confirmLabel: 'Log out',
    destructive: true,
    confirmIcon: Icons.logout,
  );
  if (!confirmed) return;

  await sl<LogoutUser>()(null); // best effort; ignore a storage failure
  session.clear();
  rootNavigatorKey.currentState?.pushAndRemoveUntil(
    LoginPage.route(),
    (_) => false,
  );
}
