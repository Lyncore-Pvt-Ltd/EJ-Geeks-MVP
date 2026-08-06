import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/invoice/domain/entities/payment_status.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_state.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_card.dart';
import 'package:ej_geek/features/search/presentation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceScreen extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const InvoiceScreen());
  const InvoiceScreen({super.key});

  void _showPaymentFilterSheet(BuildContext context) {
    final invoiceBloc = context.read<InvoiceBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final groupColor = isDark ? AppPallete.warmOnyx : Colors.grey[200];
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final handleColor = isDark ? Colors.white24 : Colors.black26;
    final activeFilter = invoiceBloc.state.paymentFilter;

    Widget filterTile({required String label, required PaymentStatus? value}) {
      final isActive = activeFilter == value;
      return ListTile(
        onTap: () {
          Navigator.pop(context);
          invoiceBloc.add(InvoicePaymentFilterChanged(value));
        },
        title: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: isActive
            ? Icon(Icons.check, color: AppPallete.emeraldTeal)
            : null,
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? AppPallete.invoiceCardGradientDark
                : AppPallete.invoiceCardGradientLight,
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Filter by payment status',
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: groupColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  filterTile(label: 'All', value: null),
                  Divider(
                    color: dividerColor,
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  filterTile(
                    label: PaymentStatus.pending.label,
                    value: PaymentStatus.pending,
                  ),
                  Divider(
                    color: dividerColor,
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  filterTile(
                    label: PaymentStatus.paid.label,
                    value: PaymentStatus.paid,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
            hintText: 'Search invoice id, name, or phone',
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
