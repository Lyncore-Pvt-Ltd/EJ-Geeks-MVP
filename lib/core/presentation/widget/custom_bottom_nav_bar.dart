import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBarTab {
  final IconData icon;
  final String text;

  const NavBarTab({required this.icon, required this.text});
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final List<NavBarTab> tabs;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicWidth(
            child: GNav(
              selectedIndex: selectedIndex,
              onTabChange: onTabChange,
              gap: 8,
              activeColor: AppPallete.dynamicBlack,
              color: isDark
                  ? AppPallete.cascadingWhite
                  : AppPallete.tricornBlack,
              tabBackgroundGradient: const LinearGradient(
                colors: [
                  Color(0xFFFF3D3D),
                  Color(0xFFFF6060),
                  Color(0xFFFF8A80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              tabBorderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              duration: const Duration(milliseconds: 300),
              tabs: tabs
                  .map((tab) => GButton(icon: tab.icon, text: tab.text))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
