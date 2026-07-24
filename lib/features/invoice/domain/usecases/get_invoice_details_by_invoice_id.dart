import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice_details_bundle.dart';
import '../repositories/invoice_repository.dart';

class GetInvoiceDetailsByInvoiceId
    implements UseCase<InvoiceDetailsBundle, String> {
  final InvoiceRepository _repository;

  GetInvoiceDetailsByInvoiceId(this._repository);

  @override
  Future<Either<Failure, InvoiceDetailsBundle>> call(String params) {
    return _repository.getInvoiceDetailsByInvoiceId(params);
  }
}
