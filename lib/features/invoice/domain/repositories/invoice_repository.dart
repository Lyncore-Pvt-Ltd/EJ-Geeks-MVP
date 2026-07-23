import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/invoice_summary.dart';
import '../entities/service_status.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, void>> upsertInvoiceDraft(String invoiceId);

  Future<Either<Failure, List<InvoiceSummary>>> getAllInvoices();

  Future<Either<Failure, void>> updateServiceStatus(
    String invoiceId,
    ServiceStatus status,
  );

  Future<Either<Failure, void>> deleteInvoice(String invoiceId);
}
