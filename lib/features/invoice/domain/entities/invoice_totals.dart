import 'package:equatable/equatable.dart';

import 'invoice_line_item.dart';

class InvoiceTotals extends Equatable {
  final double netTotal;
  final double gstAmount;
  final double discountAmount;
  final double totalAmount;

  const InvoiceTotals({
    this.netTotal = 0,
    this.gstAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
  });

  @override
  List<Object?> get props => [netTotal, gstAmount, discountAmount, totalAmount];
}

InvoiceTotals computeInvoiceTotals(
  List<InvoiceLineItem> items,
  double gstPercent,
  double discountPercent,
) {
  final net = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  final gst = net * gstPercent / 100;
  final discount = net * discountPercent / 100;
  return InvoiceTotals(
    netTotal: net,
    gstAmount: gst,
    discountAmount: discount,
    totalAmount: net + gst - discount,
  );
}
