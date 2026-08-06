import 'package:equatable/equatable.dart';

import '../../domain/entities/payment_status.dart';

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

class InvoiceServiceReverted extends InvoiceEvent {
  final String invoiceId;

  const InvoiceServiceReverted(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class InvoicePaymentMarkedPaid extends InvoiceEvent {
  final String invoiceId;

  const InvoicePaymentMarkedPaid(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class InvoicePaymentMarkedUnpaid extends InvoiceEvent {
  final String invoiceId;

  const InvoicePaymentMarkedUnpaid(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class InvoiceSearchQueryChanged extends InvoiceEvent {
  final String query;

  const InvoiceSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class InvoicePaymentFilterChanged extends InvoiceEvent {
  final PaymentStatus? filter;

  const InvoicePaymentFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class InvoiceDeleted extends InvoiceEvent {
  final String invoiceId;
  final bool deleteFiles;

  const InvoiceDeleted(this.invoiceId, {this.deleteFiles = false});

  @override
  List<Object?> get props => [invoiceId, deleteFiles];
}
