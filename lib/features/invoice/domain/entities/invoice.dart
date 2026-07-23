import 'package:equatable/equatable.dart';

import 'payment_status.dart';
import 'service_status.dart';

class Invoice extends Equatable {
  final String id;
  final ServiceStatus serviceStatus;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.serviceStatus,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    serviceStatus,
    paymentStatus,
    createdAt,
    updatedAt,
  ];
}
