import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

import 'pdf_theme.dart';

/// Loads the app's launcher icon asset for use as the PDF letterhead logo.
Future<pw.MemoryImage> loadCompanyLogo() async {
  final data = await rootBundle.load('assets/icon/EJG.png');
  return pw.MemoryImage(data.buffer.asUint8List());
}

/// Shared letterhead header: logo on the left, company contact block on the
/// right. Reused by both the invoice and inspection report PDFs.
pw.Widget pdfLetterheadHeader({
  required pw.MemoryImage logo,
  required AppPdfFonts fonts,
  required String companyName,
  required String addressLine,
  required String abn,
  required String email,
  required String phone,
}) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.ClipOval(
        child: pw.Image(logo, width: 80, height: 80, fit: pw.BoxFit.cover),
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            companyName,
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: 14,
              color: AppPdfPallete.textPrimary,
            ),
          ),
          pw.SizedBox(height: 2),
          if (addressLine.isNotEmpty)
            pw.Text(
              addressLine,
              style: pw.TextStyle(
                font: fonts.regular,
                fontSize: 10,
                color: AppPdfPallete.textSecondary,
              ),
            ),
          if (abn.isNotEmpty)
            pw.Text(
              abn,
              style: pw.TextStyle(
                font: fonts.regular,
                fontSize: 10,
                color: AppPdfPallete.textSecondary,
              ),
            ),
          pw.Text(
            email,
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 10,
              color: AppPdfPallete.textSecondary,
            ),
          ),
          pw.Text(
            phone,
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 10,
              color: AppPdfPallete.textSecondary,
            ),
          ),
        ],
      ),
    ],
  );
}

/// A section heading in the app's accent color.
pw.Widget pdfSectionHeading(String title, AppPdfFonts fonts) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        font: fonts.bold,
        fontSize: 13,
        color: AppPdfPallete.accent,
      ),
    ),
  );
}

pw.Widget pdfDivider() =>
    pw.Divider(color: AppPdfPallete.border, thickness: 1);

/// A QR code encoding [invoiceId], for a future in-app "scan PDF to find
/// invoice" lookup feature — not implemented yet, just embedded here.
pw.Widget invoiceIdQrCode(String invoiceId, {double size = 80}) {
  return pw.BarcodeWidget(
    data: invoiceId,
    barcode: pw.Barcode.qrCode(),
    drawText: false,
    width: size,
    height: size,
    color: AppPdfPallete.textPrimary,
  );
}
