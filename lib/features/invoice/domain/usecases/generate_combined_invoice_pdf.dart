import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pdf/pdf_file_writer.dart';
import '../../../../core/storage/app_storage_paths.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../inspection/domain/usecases/get_inspection_by_invoice_id.dart';
import '../../data/pdf/combined_invoice_pdf_builder.dart';
import 'get_invoice_details_by_invoice_id.dart';

class GenerateCombinedInvoicePdfParams extends Equatable {
  final String invoiceId;
  final DateTime invoiceCreatedAt;

  const GenerateCombinedInvoicePdfParams({
    required this.invoiceId,
    required this.invoiceCreatedAt,
  });

  @override
  List<Object?> get props => [invoiceId, invoiceCreatedAt];
}

/// Builds (fresh, every call — no caching) a single PDF with the invoice
/// pages followed by the inspection report pages and writes it to
/// `AppStoragePaths.combinedPdfPath`, returning the written file's path.
class GenerateCombinedInvoicePdf
    implements UseCase<String, GenerateCombinedInvoicePdfParams> {
  final GetInvoiceDetailsByInvoiceId _getInvoiceDetails;
  final GetInspectionByInvoiceId _getInspection;

  GenerateCombinedInvoicePdf(this._getInvoiceDetails, this._getInspection);

  @override
  Future<Either<Failure, String>> call(
    GenerateCombinedInvoicePdfParams params,
  ) async {
    final detailsResult = await _getInvoiceDetails(params.invoiceId);
    return detailsResult.fold((failure) async => Left(failure), (
      bundle,
    ) async {
      final inspectionResult = await _getInspection(params.invoiceId);
      final inspection = inspectionResult.fold(
        (_) => null,
        (record) => record,
      );

      try {
        final bytes = await buildCombinedInvoicePdf(
          bundle: bundle,
          inspection: inspection,
        );
        final path = await AppStoragePaths.combinedPdfPath(
          params.invoiceId,
          params.invoiceCreatedAt,
        );
        await writePdfBytes(path, bytes);
        return Right(path);
      } on StorageException catch (e) {
        return Left(StorageFailure(message: e.message));
      } catch (e) {
        return Left(StorageFailure(message: 'Failed to generate PDF: $e'));
      }
    });
  }
}
