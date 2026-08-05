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
      pw.Align(
        alignment: pw.Alignment.topLeft,
        child: pw.ClipOval(
          child: pw.Image(logo, width: 80, height: 80, fit: pw.BoxFit.cover),
        ),
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

/// A rotated "PAID" stamp with [paidLabel] (a pre-formatted date/time string)
/// below it, for overlaying near an invoice's totals once payment is
/// confirmed. Takes a plain string rather than a `DateTime` so this
/// feature-agnostic file doesn't need a date-formatting dependency.
pw.Widget pdfPaidStamp(String paidLabel, AppPdfFonts fonts) {
  return pw.Transform.rotate(
    angle: 0.35,
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: AppPdfPallete.paidBlue, width: 2),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'PAID',
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: 20,
              color: AppPdfPallete.paidBlue,
            ),
          ),
          pw.Text(
            paidLabel,
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 8,
              color: AppPdfPallete.paidBlue,
            ),
          ),
        ],
      ),
    ),
  );
}

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
