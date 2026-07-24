import 'package:ej_geek/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_state.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceScreen extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const InvoiceScreen());
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchWidget(),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                if (state.isLoading && state.invoices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.invoices.isEmpty) {
                  return const Center(child: Text('No invoices yet'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: state.invoices.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InvoiceCard(summary: state.invoices[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ──────────────────────────────────────────────────────────────
TextField searchWidget() {
  return TextField(
    decoration: InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      hintText: 'Search',
      hintStyle: GoogleFonts.inter(color: Colors.grey),
      prefixIcon: const Icon(Icons.search, color: Color(0xFF07172B), size: 20),
      suffixIcon: const Icon(Icons.tune, size: 20, color: Color(0xFF07172B)),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
