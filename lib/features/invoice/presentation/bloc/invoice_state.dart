import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice_summary.dart';

class InvoiceState extends Equatable {
  final List<InvoiceSummary> invoices;
  final bool isLoading;
  final String? errorMessage;

  const InvoiceState({
    this.invoices = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  InvoiceState copyWith({
    List<InvoiceSummary>? invoices,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [invoices, isLoading, errorMessage];
}
