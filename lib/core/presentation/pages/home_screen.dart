import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const HomeScreen());

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E&J Geek Invoice')),
      body: const Center(child: Text('Home — coming soon')),
    );
  }
}
