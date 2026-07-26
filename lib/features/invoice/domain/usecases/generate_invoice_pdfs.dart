import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pdf/pdf_file_writer.dart';
import '../../../../core/storage/app_storage_paths.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../inspection/domain/usecases/get_inspection_by_invoice_id.dart';
import '../../data/pdf/inspection_report_pdf_builder.dart';
import '../../data/pdf/invoice_pdf_builder.dart';
import 'get_invoice_details_by_invoice_id.dart';

class GenerateInvoicePdfsParams extends Equatable {
  final String invoiceId;
  final DateTime invoiceCreatedAt;

  const GenerateInvoicePdfsParams({
    required this.invoiceId,
    required this.invoiceCreatedAt,
  });

  @override
  List<Object?> get props => [invoiceId, invoiceCreatedAt];
}

class GeneratedInvoicePdfs extends Equatable {
  final String invoicePdfPath;
  final String? inspectionPdfPath;

  const GeneratedInvoicePdfs({
    required this.invoicePdfPath,
    this.inspectionPdfPath,
  });

  @override
  List<Object?> get props => [invoicePdfPath, inspectionPdfPath];
}

/// Generates the Invoice PDF and (if an inspection has been saved) the
/// Inspection Report PDF for an invoice, writing both to
/// `AppStoragePaths.invoiceFolder`.
class GenerateInvoicePdfs
    implements UseCase<GeneratedInvoicePdfs, GenerateInvoicePdfsParams> {
  final GetInvoiceDetailsByInvoiceId _getInvoiceDetails;
  final GetInspectionByInvoiceId _getInspection;

  GenerateInvoicePdfs(this._getInvoiceDetails, this._getInspection);

  @override
  Future<Either<Failure, GeneratedInvoicePdfs>> call(
    GenerateInvoicePdfsParams params,
  ) async {
    final detailsResult = await _getInvoiceDetails(params.invoiceId);
    final bundle = detailsResult.fold((failure) => null, (bundle) => bundle);
    final detailsFailure = detailsResult.fold(
      (failure) => failure,
      (_) => null,
    );
    if (bundle == null) {
      return Left(detailsFailure ?? const CacheFailure(message: 'Invoice not found'));
    }

    final inspectionResult = await _getInspection(params.invoiceId);
    final inspection = inspectionResult.fold(
      (_) => null,
      (record) => record,
    );

    try {
      final invoicePdfBytes = await buildInvoicePdf(
        bundle: bundle,
        inspection: inspection,
      );
      final invoicePdfPath = await AppStoragePaths.invoicePdfPath(
        params.invoiceId,
        params.invoiceCreatedAt,
      );
      await writePdfBytes(invoicePdfPath, invoicePdfBytes);

      String? inspectionPdfPath;
      if (inspection != null) {
        final inspectionPdfBytes = await buildInspectionReportPdf(
          inspection: inspection,
          invoiceDetails: bundle.details,
        );
        inspectionPdfPath = await AppStoragePaths.inspectionPdfPath(
          params.invoiceId,
          params.invoiceCreatedAt,
        );
        await writePdfBytes(inspectionPdfPath, inspectionPdfBytes);
      }

      return Right(
        GeneratedInvoicePdfs(
          invoicePdfPath: invoicePdfPath,
          inspectionPdfPath: inspectionPdfPath,
        ),
      );
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to generate PDF: $e'));
    }
  }
}
