import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../session/session_controller.dart';

/// Shows [child] only if the signed-in user holds [permission]; otherwise
/// [fallback] (nothing by default).
class PermissionGate extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget fallback;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final allowed = context.select<SessionController, bool>(
      (s) => s.can(permission),
    );
    return allowed ? child : fallback;
  }
}
