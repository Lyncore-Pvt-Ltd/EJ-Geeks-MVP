import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice_summary.dart';
import '../../domain/entities/payment_status.dart';

class InvoiceState extends Equatable {
  final List<InvoiceSummary> invoices;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final PaymentStatus? paymentFilter;

  const InvoiceState({
    this.invoices = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.paymentFilter,
  });

  /// [invoices] narrowed by [searchQuery] (matched against the invoice id,
  /// its shortened display form, owner name, and phone number) and
  /// [paymentFilter] (`null` means all payment statuses).
  List<InvoiceSummary> get filteredInvoices {
    final query = searchQuery.trim().toLowerCase();
    return invoices.where((summary) {
      if (paymentFilter != null && summary.paymentStatus != paymentFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      final shortId = summary.id.length > 8
          ? summary.id.substring(0, 8)
          : summary.id;
      return summary.id.toLowerCase().contains(query) ||
          shortId.toLowerCase().contains(query) ||
          summary.ownerName.toLowerCase().contains(query) ||
          summary.phoneNumber.toLowerCase().contains(query);
    }).toList();
  }

  InvoiceState copyWith({
    List<InvoiceSummary>? invoices,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    PaymentStatus? paymentFilter,
    bool clearPaymentFilter = false,
  }) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      paymentFilter: clearPaymentFilter
          ? null
          : (paymentFilter ?? this.paymentFilter),
    );
  }

  @override
  List<Object?> get props => [
    invoices,
    isLoading,
    errorMessage,
    searchQuery,
    paymentFilter,
  ];
}
