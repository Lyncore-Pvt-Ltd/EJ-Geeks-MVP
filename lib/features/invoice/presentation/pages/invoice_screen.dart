import 'package:ej_geek/features/invoice/domain/entities/payment_status.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_state.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_card.dart';
import 'package:ej_geek/features/search/presentation/widgets/filter_bottom_sheet.dart';
import 'package:ej_geek/features/search/presentation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceScreen extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const InvoiceScreen());
  const InvoiceScreen({super.key});

  void _showPaymentFilterSheet(BuildContext context) {
    final invoiceBloc = context.read<InvoiceBloc>();
    FilterBottomSheet.show<PaymentStatus?>(
      context: context,
      title: 'Filter by payment status',
      activeValue: invoiceBloc.state.paymentFilter,
      options: [
        const FilterOption(label: 'All', icon: Icons.filter_list, value: null),
        FilterOption(
          label: PaymentStatus.pending.label,
          icon: Icons.hourglass_bottom,
          value: PaymentStatus.pending,
        ),
        FilterOption(
          label: PaymentStatus.paid.label,
          icon: Icons.check_circle,
          value: PaymentStatus.paid,
        ),
      ],
      onSelected: (value) =>
          invoiceBloc.add(InvoicePaymentFilterChanged(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchBar(
            hintText: 'Search',
            onQueryChanged: (query) => context.read<InvoiceBloc>().add(
              InvoiceSearchQueryChanged(query),
            ),
            onSubmitted: (query) => context.read<InvoiceBloc>().add(
              InvoiceSearchQueryChanged(query),
            ),
            onFilterTap: () => _showPaymentFilterSheet(context),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                if (state.isLoading && state.invoices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filteredInvoices = state.filteredInvoices;
                if (state.invoices.isEmpty) {
                  return const Center(child: Text('No invoices yet'));
                }
                if (filteredInvoices.isEmpty) {
                  return const Center(child: Text('No matching invoices'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filteredInvoices.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InvoiceCard(summary: filteredInvoices[index]),
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
