import 'package:auto_flow/core/presentation/pages/settings_screen.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final itemStyle = AutoFlowTokens.title.copyWith(color: tokens.ink);

    Widget item(IconData icon, String label, VoidCallback onTap) => ListTile(
      leading: Icon(icon, color: tokens.ink),
      title: Text(label, style: itemStyle),
      minTileHeight: AfSpace.controlHeight,
      shape: const RoundedRectangleBorder(borderRadius: AfRadius.controlAll),
      onTap: onTap,
    );

    return Drawer(
      elevation: 0,
      backgroundColor: tokens.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: tokens.line)),
            ),
            child: Center(
              child: Image.asset('assets/icon/EJG.png', height: 64, width: 64),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AfSpace.s8),
              children: [
                item(Icons.home_outlined, 'Home', () {
                  // Handle Home tap
                }),
                item(
                  Icons.settings_outlined,
                  'Settings',
                  () => Navigator.push(context, SettingScreen.route()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AfSpace.s8),
            child: item(Icons.logout, 'Logout', () {}),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AfSpace.m16),
            child: Text(
              '© All Rights Reserved. LYNCORE Pvt. Ltd 2026',
              style: AutoFlowTokens.caption.copyWith(color: tokens.mute),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AfSpace.l24),
        ],
      ),
    );
  }
}
