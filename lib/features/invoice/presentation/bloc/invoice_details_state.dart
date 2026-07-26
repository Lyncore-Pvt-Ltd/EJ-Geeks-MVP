import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice_line_item.dart';
import '../../domain/entities/invoice_totals.dart';

class InvoiceDetailsState extends Equatable {
  final String ownerName;
  final String address;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final String paymentTerms;
  final String notes;
  final double vatPercent;
  final double discountPercent;
  final String appOwnerAddress;
  final List<InvoiceLineItem> items;
  final InvoiceTotals totals;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const InvoiceDetailsState({
    this.ownerName = '',
    this.address = '',
    this.issueDate,
    this.dueDate,
    this.paymentTerms = '',
    this.notes = '',
    this.vatPercent = 0,
    this.discountPercent = 0,
    this.appOwnerAddress = '',
    this.items = const [],
    this.totals = const InvoiceTotals(),
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  InvoiceDetailsState copyWith({
    String? ownerName,
    String? address,
    DateTime? issueDate,
    DateTime? dueDate,
    String? paymentTerms,
    String? notes,
    double? vatPercent,
    double? discountPercent,
    String? appOwnerAddress,
    List<InvoiceLineItem>? items,
    InvoiceTotals? totals,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
  }) {
    return InvoiceDetailsState(
      ownerName: ownerName ?? this.ownerName,
      address: address ?? this.address,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      notes: notes ?? this.notes,
      vatPercent: vatPercent ?? this.vatPercent,
      discountPercent: discountPercent ?? this.discountPercent,
      appOwnerAddress: appOwnerAddress ?? this.appOwnerAddress,
      items: items ?? this.items,
      totals: totals ?? this.totals,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? false,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    ownerName,
    address,
    issueDate,
    dueDate,
    paymentTerms,
    notes,
    vatPercent,
    discountPercent,
    appOwnerAddress,
    items,
    totals,
    isLoading,
    isSaving,
    saveSuccess,
    errorMessage,
  ];
}
