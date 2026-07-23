import 'package:equatable/equatable.dart';

import 'payment_status.dart';
import 'service_status.dart';

/// The display model for an invoice card: the persisted [Invoice] fields
/// plus vehicle/owner details read by joining the `inspections` row that
/// shares this invoice's id.
class InvoiceSummary extends Equatable {
  final String id;
  final ServiceStatus serviceStatus;
  final PaymentStatus paymentStatus;
  final String ownerName;
  final String make;
  final String model;
  final String rego;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvoiceSummary({
    required this.id,
    required this.serviceStatus,
    required this.paymentStatus,
    this.ownerName = '',
    this.make = '',
    this.model = '',
    this.rego = '',
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    serviceStatus,
    paymentStatus,
    ownerName,
    make,
    model,
    rego,
    createdAt,
    updatedAt,
  ];
}
