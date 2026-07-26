import 'package:equatable/equatable.dart';

abstract class InvoiceDetailsEvent extends Equatable {
  const InvoiceDetailsEvent();

  @override
  List<Object?> get props => [];
}

class InvoiceDetailsLoadRequested extends InvoiceDetailsEvent {
  const InvoiceDetailsLoadRequested();
}

class IssueDateChanged extends InvoiceDetailsEvent {
  final DateTime date;

  const IssueDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class DueDateChanged extends InvoiceDetailsEvent {
  final DateTime date;

  const DueDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class LineItemAdded extends InvoiceDetailsEvent {
  final String name;
  final String quantityRaw;
  final String unitPriceRaw;

  const LineItemAdded({
    required this.name,
    required this.quantityRaw,
    required this.unitPriceRaw,
  });

  @override
  List<Object?> get props => [name, quantityRaw, unitPriceRaw];
}

class LineItemEdited extends InvoiceDetailsEvent {
  final String itemId;
  final String name;
  final String quantityRaw;
  final String unitPriceRaw;

  const LineItemEdited({
    required this.itemId,
    required this.name,
    required this.quantityRaw,
    required this.unitPriceRaw,
  });

  @override
  List<Object?> get props => [itemId, name, quantityRaw, unitPriceRaw];
}

class LineItemRemoved extends InvoiceDetailsEvent {
  final String itemId;

  const LineItemRemoved(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class VatPercentChanged extends InvoiceDetailsEvent {
  final String rawValue;

  const VatPercentChanged(this.rawValue);

  @override
  List<Object?> get props => [rawValue];
}

class DiscountPercentChanged extends InvoiceDetailsEvent {
  final String rawValue;

  const DiscountPercentChanged(this.rawValue);

  @override
  List<Object?> get props => [rawValue];
}

class AppOwnerAddressChanged extends InvoiceDetailsEvent {
  final String value;

  const AppOwnerAddressChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class InvoiceDetailsSaved extends InvoiceDetailsEvent {
  final String paymentTerms;
  final String notes;

  const InvoiceDetailsSaved({required this.paymentTerms, required this.notes});

  @override
  List<Object?> get props => [paymentTerms, notes];
}
