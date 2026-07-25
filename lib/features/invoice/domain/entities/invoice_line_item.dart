import 'package:equatable/equatable.dart';

class InvoiceLineItem extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final double unitPrice;

  const InvoiceLineItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  InvoiceLineItem copyWith({
    String? id,
    String? name,
    double? quantity,
    double? unitPrice,
  }) {
    return InvoiceLineItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, unitPrice];
}
