import 'package:equatable/equatable.dart';

import 'invoice_details.dart';
import 'invoice_line_item.dart';

class InvoiceDetailsBundle extends Equatable {
  final InvoiceDetails details;
  final List<InvoiceLineItem> items;

  const InvoiceDetailsBundle({required this.details, required this.items});

  @override
  List<Object?> get props => [details, items];
}
