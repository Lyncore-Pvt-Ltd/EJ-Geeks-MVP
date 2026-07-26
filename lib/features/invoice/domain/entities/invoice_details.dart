import 'package:equatable/equatable.dart';

class InvoiceDetails extends Equatable {
  final String invoiceId;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final String paymentTerms;
  final String notes;
  final double vatPercent;
  final double discountPercent;
  final String appOwnerAddress;

  const InvoiceDetails({
    required this.invoiceId,
    this.issueDate,
    this.dueDate,
    this.paymentTerms = '',
    this.notes = '',
    this.vatPercent = 0,
    this.discountPercent = 0,
    this.appOwnerAddress = '',
  });

  @override
  List<Object?> get props => [
    invoiceId,
    issueDate,
    dueDate,
    paymentTerms,
    notes,
    vatPercent,
    discountPercent,
    appOwnerAddress,
  ];
}
