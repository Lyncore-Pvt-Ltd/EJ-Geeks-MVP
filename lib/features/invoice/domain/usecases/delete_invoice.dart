import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invoice_repository.dart';

class DeleteInvoiceParams extends Equatable {
  final String invoiceId;
  final bool deleteFiles;

  const DeleteInvoiceParams({
    required this.invoiceId,
    this.deleteFiles = false,
  });

  @override
  List<Object?> get props => [invoiceId, deleteFiles];
}

class DeleteInvoice implements UseCase<void, DeleteInvoiceParams> {
  final InvoiceRepository _repository;

  DeleteInvoice(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteInvoiceParams params) {
    return _repository.deleteInvoice(
      params.invoiceId,
      deleteFiles: params.deleteFiles,
    );
  }
}
