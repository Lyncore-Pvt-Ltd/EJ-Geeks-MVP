import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/custom_appbar.dart';
import '../widget/custom_settings_row.dart';
import '../widget/custom_theme_switch.dart';

class SettingScreen extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const SettingScreen());
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ""),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(context),
            const SizedBox(height: 30),
            _buildSettingsSection(context),
            const SizedBox(height: 30),
            _buildAppSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFF6060),
              child: Icon(Icons.person, size: 50, color: AppPallete.hypnotic),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "-",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF07172B),
            ),
          ),
          const SizedBox(height: 4),
          Text("-", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Settings',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 5.0),
          // Settings Card
          Container(
            decoration: BoxDecoration(
              color: AppPallete.nebulousWhite.withValues(alpha: 0.05),

              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomSettingsRow(
                  icon: Icons.person_outline,
                  title: 'Send Request to Edit Profile',
                  trailing: const Icon(Icons.chevron_right, size: 24),
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                CustomSettingsRow(
                  icon: Icons.lock_outline,
                  title: 'Reset Password',
                  trailing: const Icon(Icons.chevron_right, size: 24),
                  isLast: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 5.0),
          // Settings Card
          Container(
            decoration: BoxDecoration(
              color: AppPallete.nebulousWhite.withValues(alpha: 0.05),

              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomThemeSwitch(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: themeController.isDarkMode,
              onChanged: themeController.toggleDarkMode,
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }
}
