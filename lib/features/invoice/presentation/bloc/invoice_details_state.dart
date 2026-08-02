import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice_line_item.dart';
import '../../domain/entities/invoice_totals.dart';

class InvoiceDetailsState extends Equatable {
  final DateTime? issueDate;
  final DateTime? dueDate;
  final String paymentTerms;
  final String notes;
  final double gstPercent;
  final double discountPercent;
  final String appOwnerAddress;
  final List<InvoiceLineItem> items;
  final InvoiceTotals totals;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final bool isSending;
  final bool sendSuccess;
  final bool needsRegenerationConfirmation;
  final String? invoicePdfPath;
  final String? inspectionPdfPath;
  final String? errorMessage;

  const InvoiceDetailsState({
    this.issueDate,
    this.dueDate,
    this.paymentTerms = '',
    this.notes = '',
    this.gstPercent = 0,
    this.discountPercent = 0,
    this.appOwnerAddress = '',
    this.items = const [],
    this.totals = const InvoiceTotals(),
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.isSending = false,
    this.sendSuccess = false,
    this.needsRegenerationConfirmation = false,
    this.invoicePdfPath,
    this.inspectionPdfPath,
    this.errorMessage,
  });

  InvoiceDetailsState copyWith({
    DateTime? issueDate,
    DateTime? dueDate,
    String? paymentTerms,
    String? notes,
    double? gstPercent,
    double? discountPercent,
    String? appOwnerAddress,
    List<InvoiceLineItem>? items,
    InvoiceTotals? totals,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    bool? isSending,
    bool? sendSuccess,
    bool? needsRegenerationConfirmation,
    String? invoicePdfPath,
    String? inspectionPdfPath,
    String? errorMessage,
  }) {
    return InvoiceDetailsState(
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      notes: notes ?? this.notes,
      gstPercent: gstPercent ?? this.gstPercent,
      discountPercent: discountPercent ?? this.discountPercent,
      appOwnerAddress: appOwnerAddress ?? this.appOwnerAddress,
      items: items ?? this.items,
      totals: totals ?? this.totals,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? false,
      isSending: isSending ?? this.isSending,
      sendSuccess: sendSuccess ?? false,
      needsRegenerationConfirmation: needsRegenerationConfirmation ?? false,
      invoicePdfPath: invoicePdfPath ?? this.invoicePdfPath,
      inspectionPdfPath: inspectionPdfPath ?? this.inspectionPdfPath,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    issueDate,
    dueDate,
    paymentTerms,
    notes,
    gstPercent,
    discountPercent,
    appOwnerAddress,
    items,
    totals,
    isLoading,
    isSaving,
    saveSuccess,
    isSending,
    sendSuccess,
    needsRegenerationConfirmation,
    invoicePdfPath,
    inspectionPdfPath,
    errorMessage,
  ];
}
