import 'package:ej_geek/core/presentation/widget/custom_appbar.dart';
import 'package:ej_geek/core/presentation/widget/custom_drawer.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const DashboardScreen());
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(title: ''),
      body: const Center(child: Text('Home — coming soon')),
    );
  }
}
