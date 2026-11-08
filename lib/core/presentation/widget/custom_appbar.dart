import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const CustomAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return AppBar(
      title: Text(
        title ?? 'Default Title',
        style: AutoFlowTokens.title.copyWith(color: tokens.ink),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AfSpace.m16),
          // Decorative until accounts exist; nothing to announce or tap.
          child: ExcludeSemantics(
            child: CircleAvatar(
              radius: 15,
              backgroundColor: tokens.soft,
              child: Icon(Icons.person, size: 18, color: tokens.mute),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
