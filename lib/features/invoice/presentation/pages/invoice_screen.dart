import 'package:flutter/material.dart';

class InvoiceScreen extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const InvoiceScreen());
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E&J Geek Invoice')),
      body: const Center(
        child: Text('this is from features/invoice — coming soon'),
      ),
    );
  }
}
