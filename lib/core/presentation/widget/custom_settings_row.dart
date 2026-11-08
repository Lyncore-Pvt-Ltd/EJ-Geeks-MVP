import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

class CustomSettingsRow extends StatelessWidget {
  const CustomSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.isLast = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return AfPressable(
      onTap: onTap,
      pressedScale: 0.98,
      focusRadius: AfRadius.cardAll,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: AfRadius.cardAll,
          border: Border.all(color: tokens.line),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AfSpace.m16,
            vertical: AfSpace.s12,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.soft,
                  borderRadius: AfRadius.smallAll,
                ),
                child: Icon(icon, size: 20, color: tokens.ink),
              ),
              const SizedBox(width: AfSpace.m16),
              Expanded(
                child: Text(
                  title,
                  style: AutoFlowTokens.title.copyWith(color: tokens.ink),
                ),
              ),
              IconTheme.merge(
                data: IconThemeData(color: tokens.mute),
                child: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
