import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invoice_repository.dart';

class DeleteInvoice implements UseCase<void, String> {
  final InvoiceRepository _repository;

  DeleteInvoice(this._repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repository.deleteInvoice(params);
  }
}
