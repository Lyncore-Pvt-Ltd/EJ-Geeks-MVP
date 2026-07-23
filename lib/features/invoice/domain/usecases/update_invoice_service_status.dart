import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service_status.dart';
import '../repositories/invoice_repository.dart';

class UpdateInvoiceServiceStatusParams extends Equatable {
  final String invoiceId;
  final ServiceStatus status;

  const UpdateInvoiceServiceStatusParams({
    required this.invoiceId,
    required this.status,
  });

  @override
  List<Object?> get props => [invoiceId, status];
}

class UpdateInvoiceServiceStatus
    implements UseCase<void, UpdateInvoiceServiceStatusParams> {
  final InvoiceRepository _repository;

  UpdateInvoiceServiceStatus(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateInvoiceServiceStatusParams params) {
    return _repository.updateServiceStatus(params.invoiceId, params.status);
  }
}
