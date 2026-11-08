import 'package:auto_flow/core/presentation/widgets/af/af_spinner.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:auto_flow/features/invoice/domain/entities/payment_status.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_state.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_card.dart';
import 'package:auto_flow/features/search/presentation/widgets/filter_bottom_sheet.dart';
import 'package:auto_flow/features/search/presentation/widgets/search_bar.dart';
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
    final tokens = AutoFlowTokens.of(context);
    final emptyStyle = AutoFlowTokens.body.copyWith(color: tokens.mute2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AfSpace.gutter,
        AfSpace.s12,
        AfSpace.gutter,
        0,
      ),
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
          const SizedBox(height: AfSpace.m16),
          Expanded(
            child: BlocConsumer<InvoiceBloc, InvoiceState>(
              listenWhen: (previous, current) =>
                  previous.invoices != current.invoices,
              listener: (context, state) =>
                  context.read<DashboardProvider>().refresh(),
              builder: (context, state) {
                if (state.isLoading && state.invoices.isEmpty) {
                  return Center(
                    child: AfSpinner(
                      size: 24,
                      color: AutoFlowTokens.accent,
                      track: tokens.line,
                    ),
                  );
                }
                final filteredInvoices = state.filteredInvoices;
                if (state.invoices.isEmpty) {
                  return Center(
                    child: Text('No invoices yet', style: emptyStyle),
                  );
                }
                if (filteredInvoices.isEmpty) {
                  return Center(
                    child: Text('No matching invoices', style: emptyStyle),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<InvoiceBloc>().add(
                    const InvoiceListRequested(),
                  ),
                  color: AutoFlowTokens.onAccent,
                  backgroundColor: AutoFlowTokens.accent,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: 100 + MediaQuery.of(context).padding.bottom,
                    ),
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AfSpace.s12),
                        child: InvoiceCard(summary: filteredInvoices[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
