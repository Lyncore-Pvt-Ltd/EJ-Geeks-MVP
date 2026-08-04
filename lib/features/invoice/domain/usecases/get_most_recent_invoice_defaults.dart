import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice_defaults.dart';
import '../repositories/invoice_repository.dart';

class GetMostRecentInvoiceDefaults implements UseCase<InvoiceDefaults, void> {
  final InvoiceRepository _repository;

  GetMostRecentInvoiceDefaults(this._repository);

  @override
  Future<Either<Failure, InvoiceDefaults>> call(void params) {
    return _repository.getMostRecentInvoiceDefaults();
  }
}
