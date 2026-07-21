import 'package:ej_geek/core/presentation/widget/custom_appbar.dart';
import 'package:ej_geek/core/presentation/widget/custom_bottom_nav_bar.dart';
import 'package:ej_geek/core/presentation/widget/custom_drawer.dart';
import 'package:ej_geek/features/dashboard/presentation/pages/home_screen.dart';
import 'package:ej_geek/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:ej_geek/features/invoice/presentation/pages/invoice_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const DashboardScreen());
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    NavBarTab(icon: Icons.home, text: 'Home'),
    NavBarTab(icon: Icons.receipt_long_rounded, text: 'Invoices'),
  ];

  static const _pages = [HomeScreen(), InvoiceScreen()];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: Scaffold(
        extendBody: true,
        drawer: CustomDrawer(),
        appBar: CustomAppBar(title: ''),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          tabs: _tabs,
          onTabChange: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
