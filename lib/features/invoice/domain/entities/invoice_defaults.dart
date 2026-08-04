import 'package:equatable/equatable.dart';

/// The most recently saved App Owner Address / Payment Terms across all
/// invoices, used to seed those fields on a brand-new invoice that has no
/// saved row of its own yet.
class InvoiceDefaults extends Equatable {
  final String? appOwnerAddress;
  final String? paymentTerms;

  const InvoiceDefaults({this.appOwnerAddress, this.paymentTerms});

  @override
  List<Object?> get props => [appOwnerAddress, paymentTerms];
}
