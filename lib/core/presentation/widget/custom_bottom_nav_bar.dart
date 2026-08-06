import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

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
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.whiteout : AppPallete.dynamicBlack,
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
                  activeColor: isDark
                      ? AppPallete.cascadingWhite
                      : AppPallete.tricornBlack,
                  color: isDark
                      ? AppPallete.tricornBlack
                      : AppPallete.cascadingWhite,
                  tabBackgroundGradient: LinearGradient(
                    colors: isDark
                        ? [AppPallete.dynamicBlack, AppPallete.dynamicBlack]
                        : [
                            AppPallete.cascadingWhite,
                            AppPallete.cascadingWhite,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  tabBorderRadius: 20,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  duration: const Duration(milliseconds: 300),
                  tabs: tabs
                      .map((tab) => GButton(icon: tab.icon, text: tab.text))
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppPallete.whiteout : AppPallete.dynamicBlack,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () async {
                  final invoiceBloc = context.read<InvoiceBloc>();
                  await InvoiceBottomSheet.show(context);
                  invoiceBloc.add(const InvoiceListRequested());
                },
                child: Icon(
                  Icons.add,
                  color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
