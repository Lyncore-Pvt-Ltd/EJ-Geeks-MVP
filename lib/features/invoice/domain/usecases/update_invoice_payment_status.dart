import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_status.dart';
import '../repositories/invoice_repository.dart';

class UpdateInvoicePaymentStatusParams extends Equatable {
  final String invoiceId;
  final PaymentStatus status;

  const UpdateInvoicePaymentStatusParams({
    required this.invoiceId,
    required this.status,
  });

  @override
  List<Object?> get props => [invoiceId, status];
}

class UpdateInvoicePaymentStatus
    implements UseCase<void, UpdateInvoicePaymentStatusParams> {
  final InvoiceRepository _repository;

  UpdateInvoicePaymentStatus(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateInvoicePaymentStatusParams params) {
    return _repository.updatePaymentStatus(params.invoiceId, params.status);
  }
}
