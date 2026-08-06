import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../../inspection/domain/entities/inspection_record.dart';
import '../../domain/entities/invoice_details_bundle.dart';
import 'inspection_report_pdf_builder.dart';
import 'invoice_pdf_builder.dart';

/// Builds a single PDF containing the invoice pages followed by the
/// inspection report pages (when an inspection has been saved), sharing one
/// [pw.Document] rather than merging two already-rendered PDF files — this
/// keeps the output vector-based and reuses [addInvoicePdfPages]'s existing
/// PAID-stamp logic unchanged.
Future<Uint8List> buildCombinedInvoicePdf({
  required InvoiceDetailsBundle bundle,
  required InspectionRecord? inspection,
}) async {
  final doc = pw.Document();
  await addInvoicePdfPages(doc, bundle: bundle, inspection: inspection);
  if (inspection != null) {
    await addInspectionReportPdfPages(
      doc,
      inspection: inspection,
      invoiceDetails: bundle.details,
    );
  }
  return doc.save();
}
