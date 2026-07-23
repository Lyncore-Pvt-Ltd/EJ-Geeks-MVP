import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invoice_repository.dart';

class UpsertInvoiceDraft implements UseCase<void, String> {
  final InvoiceRepository _repository;

  UpsertInvoiceDraft(this._repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repository.upsertInvoiceDraft(params);
  }
}
