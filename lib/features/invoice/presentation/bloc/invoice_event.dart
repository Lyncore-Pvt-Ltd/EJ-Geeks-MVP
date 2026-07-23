import 'package:equatable/equatable.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class InvoiceListRequested extends InvoiceEvent {
  const InvoiceListRequested();
}

class InvoiceServiceCompleted extends InvoiceEvent {
  final String invoiceId;

  const InvoiceServiceCompleted(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class InvoiceDeleted extends InvoiceEvent {
  final String invoiceId;

  const InvoiceDeleted(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}
