import 'package:equatable/equatable.dart';

import 'invoice_line_item.dart';

class InvoiceTotals extends Equatable {
  final double netTotal;
  final double vatAmount;
  final double discountAmount;
  final double totalAmount;

  const InvoiceTotals({
    this.netTotal = 0,
    this.vatAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
  });

  @override
  List<Object?> get props => [netTotal, vatAmount, discountAmount, totalAmount];
}

InvoiceTotals computeInvoiceTotals(
  List<InvoiceLineItem> items,
  double vatPercent,
  double discountPercent,
) {
  final net = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  final vat = net * vatPercent / 100;
  final discount = net * discountPercent / 100;
  return InvoiceTotals(
    netTotal: net,
    vatAmount: vat,
    discountAmount: discount,
    totalAmount: net + vat - discount,
  );
}
