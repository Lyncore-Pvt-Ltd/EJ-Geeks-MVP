import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pdf/pdf_file_writer.dart';
import '../../../../core/storage/app_storage_paths.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../inspection/domain/entities/inspection_record.dart';
import '../../../inspection/domain/usecases/get_inspection_by_invoice_id.dart';
import '../../data/pdf/inspection_report_pdf_builder.dart';
import '../../data/pdf/invoice_pdf_builder.dart';
import '../entities/invoice_details.dart';
import '../entities/invoice_line_item.dart';
import 'get_invoice_details_by_invoice_id.dart';
import 'update_pdf_content_signature.dart';

class GenerateInvoicePdfsParams extends Equatable {
  final String invoiceId;
  final DateTime invoiceCreatedAt;

  /// Bypasses the "content unchanged since last generate" short-circuit —
  /// set after the user has confirmed they want to regenerate despite
  /// detected changes (see [PdfRegenerationConfirmationRequired]).
  final bool forceRegenerate;

  const GenerateInvoicePdfsParams({
    required this.invoiceId,
    required this.invoiceCreatedAt,
    this.forceRegenerate = false,
  });

  @override
  List<Object?> get props => [invoiceId, invoiceCreatedAt, forceRegenerate];
}

/// Outcome of a [GenerateInvoicePdfs] call: either the PDFs are ready
/// ([GeneratedInvoicePdfs], freshly built or reused unchanged), or the
/// content has changed since the last generate and the caller must confirm
/// with the user before rebuilding ([PdfRegenerationConfirmationRequired]).
sealed class GenerateInvoicePdfsResult extends Equatable {
  const GenerateInvoicePdfsResult();
}

class GeneratedInvoicePdfs extends GenerateInvoicePdfsResult {
  final String invoicePdfPath;
  final String? inspectionPdfPath;

  const GeneratedInvoicePdfs({
    required this.invoicePdfPath,
    this.inspectionPdfPath,
  });

  @override
  List<Object?> get props => [invoicePdfPath, inspectionPdfPath];
}

class PdfRegenerationConfirmationRequired extends GenerateInvoicePdfsResult {
  const PdfRegenerationConfirmationRequired();

  @override
  List<Object?> get props => [];
}

/// Generates the Invoice PDF and (if an inspection has been saved) the
/// Inspection Report PDF for an invoice, writing both to
/// `AppStoragePaths.invoiceFolder`.
///
/// Skips rebuilding when nothing has changed since the last successful
/// generate (tracked via `InvoiceDetails.pdfContentSignature`), and asks
/// for confirmation via [PdfRegenerationConfirmationRequired] when content
/// has changed and [GenerateInvoicePdfsParams.forceRegenerate] wasn't set.
class GenerateInvoicePdfs
    implements UseCase<GenerateInvoicePdfsResult, GenerateInvoicePdfsParams> {
  final GetInvoiceDetailsByInvoiceId _getInvoiceDetails;
  final GetInspectionByInvoiceId _getInspection;
  final UpdatePdfContentSignature _updatePdfContentSignature;

  GenerateInvoicePdfs(
    this._getInvoiceDetails,
    this._getInspection,
    this._updatePdfContentSignature,
  );

  @override
  Future<Either<Failure, GenerateInvoicePdfsResult>> call(
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

    final currentSignature = _buildContentSignature(
      details: bundle.details,
      items: bundle.items,
      inspection: inspection,
    );
    final unchanged = bundle.details.pdfContentSignature == currentSignature;

    if (unchanged) {
      final existingInvoicePath = await AppStoragePaths.invoicePdfPath(
        params.invoiceId,
        params.invoiceCreatedAt,
      );
      final invoiceFileExists = await File(existingInvoicePath).exists();

      String? existingInspectionPath;
      var inspectionFileOk = true;
      if (inspection != null) {
        existingInspectionPath = await AppStoragePaths.inspectionPdfPath(
          params.invoiceId,
          params.invoiceCreatedAt,
        );
        inspectionFileOk = await File(existingInspectionPath).exists();
      }

      if (invoiceFileExists && inspectionFileOk) {
        return Right(
          GeneratedInvoicePdfs(
            invoicePdfPath: existingInvoicePath,
            inspectionPdfPath: inspection != null ? existingInspectionPath : null,
          ),
        );
      }
      // Signature matches but a file is missing (e.g. cleared storage) —
      // fall through and rebuild; nothing to confirm since there's nothing
      // to lose.
    } else if (bundle.details.pdfContentSignature != null &&
        !params.forceRegenerate) {
      return const Right(PdfRegenerationConfirmationRequired());
    }

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

      await _updatePdfContentSignature(
        UpdatePdfContentSignatureParams(
          invoiceId: params.invoiceId,
          signature: currentSignature,
        ),
      );

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

  String _buildContentSignature({
    required InvoiceDetails details,
    required List<InvoiceLineItem> items,
    required InspectionRecord? inspection,
  }) {
    final payload = {
      'issueDate': details.issueDate?.toIso8601String(),
      'dueDate': details.dueDate?.toIso8601String(),
      'paymentTerms': details.paymentTerms,
      'notes': details.notes,
      'gstPercent': details.gstPercent,
      'discountPercent': details.discountPercent,
      'appOwnerAddress': details.appOwnerAddress,
      'paymentStatus': details.paymentStatus.toDb(),
      'paidAt': details.paidAt?.toIso8601String(),
      'items': items
          .map((i) => [i.id, i.name, i.quantity, i.unitPrice])
          .toList(),
      'vehicleDetails': inspection == null
          ? null
          : [
              inspection.vehicleDetails.ownerName,
              inspection.vehicleDetails.address,
              inspection.vehicleDetails.make,
              inspection.vehicleDetails.model,
              inspection.vehicleDetails.rego,
              inspection.vehicleDetails.year,
              inspection.vehicleDetails.odometer,
              inspection.vehicleDetails.vin,
              inspection.vehicleDetails.engineNo,
            ],
      'sections': inspection?.sections
          .map(
            (s) => [
              s.name,
              s.comment,
              s.items.map((it) => [it.label, it.rating?.name]).toList(),
            ],
          )
          .toList(),
      'imagePaths': inspection?.imagePaths,
    };
    return jsonEncode(payload);
  }
}
