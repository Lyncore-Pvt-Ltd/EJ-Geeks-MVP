import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

import 'custom_settings_row.dart';

class CustomThemeSwitch extends StatelessWidget {
  const CustomThemeSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return CustomSettingsRow(
      icon: icon,
      title: title,
      isLast: isLast,
      // The whole row toggles, not just the switch thumb.
      onTap: () => onChanged(!value),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AutoFlowTokens.accent,
        inactiveTrackColor: tokens.soft,
        inactiveThumbColor: tokens.mute,
        trackOutlineColor: WidgetStatePropertyAll(tokens.line),
      ),
    );
  }
}
