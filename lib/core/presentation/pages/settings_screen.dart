import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../widget/custom_appbar.dart';
import '../widget/custom_settings_row.dart';
import '../widget/custom_theme_switch.dart';
import '../widgets/about/about_info_dialog.dart';

class SettingScreen extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const SettingScreen());
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ""),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AfSpace.l24),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: AfSpace.sectionGap),
            _buildSettingsSection(context),
            const SizedBox(height: AfSpace.sectionGap),
            _buildAppSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AfSpace.gutter),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AutoFlowTokens.cardShadow,
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: tokens.soft,
              child: Icon(Icons.person, size: 48, color: tokens.mute),
            ),
          ),
          const SizedBox(height: AfSpace.m16),
          Text("-", style: AutoFlowTokens.title.copyWith(color: tokens.ink)),
          const SizedBox(height: AfSpace.xs4),
          Text("-", style: AutoFlowTokens.caption.copyWith(color: tokens.mute)),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final tokens = AutoFlowTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AfSpace.s8),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: AutoFlowTokens.caption.copyWith(color: tokens.mute),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AfSpace.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, 'Profile Settings'),
          CustomSettingsRow(
            icon: Icons.person_outline,
            title: 'Send Request to Edit Profile',
            trailing: const Icon(Icons.chevron_right, size: 24),
            onTap: () {},
          ),
          const SizedBox(height: AfSpace.s8),
          CustomSettingsRow(
            icon: Icons.lock_outline,
            title: 'Reset Password',
            trailing: const Icon(Icons.chevron_right, size: 24),
            isLast: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AfSpace.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, 'App Settings'),
          CustomThemeSwitch(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            value: themeController.isDarkMode,
            onChanged: themeController.toggleDarkMode,
          ),
          const SizedBox(height: AfSpace.s8),
          CustomSettingsRow(
            icon: Icons.info_outline,
            title: 'About',
            trailing: const Icon(Icons.chevron_right, size: 24),
            isLast: true,
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AboutInfoDialog(packageInfo: packageInfo),
    );
  }
}
