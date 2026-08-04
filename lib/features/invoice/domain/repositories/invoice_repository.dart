import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/invoice_details.dart';
import '../entities/invoice_details_bundle.dart';
import '../entities/invoice_line_item.dart';
import '../entities/invoice_summary.dart';
import '../entities/payment_status.dart';
import '../entities/service_status.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, void>> upsertInvoiceDraft(String invoiceId);

  Future<Either<Failure, List<InvoiceSummary>>> getAllInvoices();

  Future<Either<Failure, void>> updateServiceStatus(
    String invoiceId,
    ServiceStatus status,
  );

  Future<Either<Failure, void>> updatePaymentStatus(
    String invoiceId,
    PaymentStatus status,
  );

  Future<Either<Failure, void>> deleteInvoice(
    String invoiceId, {
    bool deleteFiles = false,
  });

  Future<Either<Failure, void>> saveInvoiceDetails(
    InvoiceDetails details,
    List<InvoiceLineItem> items,
  );

  Future<Either<Failure, InvoiceDetailsBundle>> getInvoiceDetailsByInvoiceId(
    String invoiceId,
  );

  Future<Either<Failure, void>> updatePdfContentSignature(
    String invoiceId,
    String? signature,
  );
}
