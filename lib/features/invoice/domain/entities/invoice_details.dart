import 'package:equatable/equatable.dart';

class InvoiceDetails extends Equatable {
  final String invoiceId;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final String paymentTerms;
  final String notes;
  final double gstPercent;
  final double discountPercent;
  final String appOwnerAddress;

  /// Canonical JSON snapshot of every field that fed the last successful
  /// PDF generation for this invoice (see `GenerateInvoicePdfs`). Compared
  /// against a freshly computed signature to decide whether "Generate" can
  /// reuse the existing PDFs instead of rebuilding them.
  final String? pdfContentSignature;

  const InvoiceDetails({
    required this.invoiceId,
    this.issueDate,
    this.dueDate,
    this.paymentTerms = '',
    this.notes = '',
    this.gstPercent = 0,
    this.discountPercent = 0,
    this.appOwnerAddress = '',
    this.pdfContentSignature,
  });

  @override
  List<Object?> get props => [
    invoiceId,
    issueDate,
    dueDate,
    paymentTerms,
    notes,
    gstPercent,
    discountPercent,
    appOwnerAddress,
    pdfContentSignature,
  ];
}
