import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice_summary.dart';
import '../repositories/invoice_repository.dart';

class GetAllInvoices implements UseCase<List<InvoiceSummary>, void> {
  final InvoiceRepository _repository;

  GetAllInvoices(this._repository);

  @override
  Future<Either<Failure, List<InvoiceSummary>>> call(void params) {
    return _repository.getAllInvoices();
  }
}
