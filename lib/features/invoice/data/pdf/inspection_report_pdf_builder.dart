import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../../../core/pdf/pdf_document_builder.dart';
import '../../../../core/pdf/pdf_theme.dart';
import '../../../inspection/domain/entities/inspection_record.dart';
import '../../data/constants/company_details.dart';
import '../../data/constants/invoice_date_format.dart';
import '../../data/constants/invoice_number_formatter.dart';
import '../../domain/entities/invoice_details.dart';

/// Builds the Inspection Report PDF: a cover page (vehicle summary + photo)
/// followed by one checklist table per section and a generic photo gallery.
Future<Uint8List> buildInspectionReportPdf({
  required InspectionRecord inspection,
  required InvoiceDetails invoiceDetails,
}) async {
  final fonts = await AppPdfFonts.load();
  final logo = await loadCompanyLogo();
  final vehicle = inspection.vehicleDetails;

  final doc = pw.Document();

  final coverImage = inspection.imagePaths.isNotEmpty
      ? pw.MemoryImage(File(inspection.imagePaths.first).readAsBytesSync())
      : null;

  doc.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pdfLetterheadHeader(
            logo: logo,
            fonts: fonts,
            companyName: kCompanyName,
            addressLine: invoiceDetails.appOwnerAddress,
            abn: kCompanyAbn,
            email: kCompanyEmail,
            phone: kCompanyPhone,
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'VEHICLE INSPECTION REPORT',
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: 18,
              color: AppPdfPallete.accent,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pdfSectionHeading('Vehicle Details', fonts),
                    _detailRow('Make:', vehicle.make, fonts),
                    _detailRow('Model:', vehicle.model, fonts),
                    _detailRow('Rego:', vehicle.rego, fonts),
                    _detailRow('Year:', vehicle.year, fonts),
                    _detailRow('Odometer:', vehicle.odometer, fonts),
                    _detailRow('VIN:', vehicle.vin, fonts),
                    _detailRow('Engine No:', vehicle.engineNo, fonts),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: coverImage != null
                    ? pw.Image(coverImage, fit: pw.BoxFit.cover, height: 160)
                    : pw.Container(
                        height: 160,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: AppPdfPallete.background,
                          border: pw.Border.all(color: AppPdfPallete.border),
                        ),
                        child: pw.Text(
                          'No photo available',
                          style: pw.TextStyle(
                            font: fonts.regular,
                            fontSize: 10,
                            color: AppPdfPallete.textSecondary,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pdfDivider(),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _detailRow(
                      'Customer:',
                      vehicle.ownerName.isEmpty
                          ? 'Unnamed Owner'
                          : vehicle.ownerName,
                      fonts,
                    ),
                    _detailRow(
                      'Date:',
                      invoiceDetails.issueDate != null
                          ? formatInvoiceDate(invoiceDetails.issueDate!)
                          : '-',
                      fonts,
                    ),
                    _detailRow('Address:', vehicle.address, fonts),
                    _detailRow(
                      'Phone:',
                      vehicle.phoneNumber.isEmpty
                          ? ''
                          : '+61 ${vehicle.phoneNumber}',
                      fonts,
                    ),
                    _detailRow(
                      'Job No.:',
                      formatInvoiceNumber(inspection.invoiceId),
                      fonts,
                    ),
                  ],
                ),
              ),
              invoiceIdQrCode(inspection.invoiceId, size: 64),
            ],
          ),
        ],
      ),
    ),
  );

  for (final section in inspection.sections) {
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        build: (context) => [
          pdfSectionHeading(section.name, fonts),
          pw.TableHelper.fromTextArray(
            headers: ['Category', 'Rating'],
            data: section.items
                .map((item) => [item.label, item.rating?.label ?? '-'])
                .toList(),
            headerStyle: pw.TextStyle(
              font: fonts.bold,
              fontSize: 10,
              color: AppPdfPallete.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: AppPdfPallete.textPrimary,
            ),
            cellStyle: pw.TextStyle(
              font: fonts.regular,
              fontSize: 10,
              color: AppPdfPallete.textPrimary,
            ),
            border: pw.TableBorder.all(color: AppPdfPallete.border),
          ),
          if (section.imagePaths.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Photos:',
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 11,
                color: AppPdfPallete.textPrimary,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              children: section.imagePaths
                  .map(
                    (path) => pw.SizedBox(
                      width: 240,
                      height: 180,
                      child: pw.Image(
                        pw.MemoryImage(File(path).readAsBytesSync()),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (section.comment.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Comments:',
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 11,
                color: AppPdfPallete.textPrimary,
              ),
            ),
            pw.SizedBox(height: 4),
            ...section.comment
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .map(
                  (line) => pw.Text(
                    '• ${line.trim()}',
                    style: pw.TextStyle(
                      font: fonts.regular,
                      fontSize: 10,
                      color: AppPdfPallete.textPrimary,
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  // Generic photo gallery: any images beyond the one already shown on the
  // cover page, from the global (not section-scoped) picker only —
  // per-section photos are rendered on their own section's page above.
  final galleryPaths = inspection.imagePaths.skip(1).toList();
  if (galleryPaths.isNotEmpty) {
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        build: (context) => [
          pdfSectionHeading('Vehicle Photos', fonts),
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: galleryPaths
                .map(
                  (path) => pw.SizedBox(
                    width: 240,
                    height: 180,
                    child: pw.Image(
                      pw.MemoryImage(File(path).readAsBytesSync()),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  return doc.save();
}

pw.Widget _detailRow(String label, String value, AppPdfFonts fonts) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 10,
              color: AppPdfPallete.textSecondary,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value.isEmpty ? '-' : value,
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: 10,
              color: AppPdfPallete.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}
