import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../../../core/pdf/pdf_document_builder.dart';
import '../../../../core/pdf/pdf_theme.dart';
import '../../../inspection/domain/entities/inspection_record.dart';
import '../../data/constants/company_details.dart';
import '../../data/constants/invoice_date_format.dart';
import '../../data/constants/invoice_number_formatter.dart';
import '../../domain/entities/invoice_details_bundle.dart';
import '../../domain/entities/invoice_totals.dart';
import '../../presentation/widgets/invoice_screens/currency_format.dart';

/// Builds the Invoice PDF: letterhead, bill-to, invoice meta, line items
/// table, totals, payment details and terms & conditions.
Future<Uint8List> buildInvoicePdf({
  required InvoiceDetailsBundle bundle,
  required InspectionRecord? inspection,
}) async {
  final fonts = await AppPdfFonts.load();
  final logo = await loadCompanyLogo();

  final details = bundle.details;
  final totals = computeInvoiceTotals(
    bundle.items,
    details.vatPercent,
    details.discountPercent,
  );

  final ownerName = inspection?.vehicleDetails.ownerName ?? '';
  final ownerAddress = inspection?.vehicleDetails.address ?? '';

  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
      build: (context) => [
        pdfLetterheadHeader(
          logo: logo,
          fonts: fonts,
          companyName: kCompanyName,
          addressLine: details.appOwnerAddress,
          email: kCompanyEmail,
          phone: kCompanyPhone,
        ),
        pw.SizedBox(height: 24),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pdfSectionHeading('BILL TO', fonts),
                  pw.Text(
                    ownerName.isEmpty ? 'Unnamed Owner' : ownerName,
                    style: pw.TextStyle(
                      font: fonts.bold,
                      fontSize: 11,
                      color: AppPdfPallete.textPrimary,
                    ),
                  ),
                  if (ownerAddress.isNotEmpty)
                    pw.Text(
                      ownerAddress,
                      style: pw.TextStyle(
                        font: fonts.regular,
                        fontSize: 10,
                        color: AppPdfPallete.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pdfSectionHeading('INVOICE', fonts),
                  _metaRow(
                    'Invoice No:',
                    formatInvoiceNumber(details.invoiceId),
                    fonts,
                  ),
                  _metaRow(
                    'Issue Date:',
                    details.issueDate != null
                        ? formatInvoiceDate(details.issueDate!)
                        : '-',
                    fonts,
                  ),
                  _metaRow(
                    'Due Date:',
                    details.dueDate != null
                        ? formatInvoiceDate(details.dueDate!)
                        : '-',
                    fonts,
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.TableHelper.fromTextArray(
          headers: ['Description', 'Quantity', 'Unit Price', 'Amount'],
          data: bundle.items
              .map(
                (item) => [
                  item.name,
                  trimmedAmount(item.quantity),
                  formatAud(item.unitPrice),
                  formatAud(item.totalPrice),
                ],
              )
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
          cellAlignments: const {
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
          },
          border: pw.TableBorder.all(color: AppPdfPallete.border),
        ),
        pw.SizedBox(height: 16),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 220,
            child: pw.Column(
              children: [
                _totalRow('Subtotal', formatAud(totals.netTotal), fonts),
                _totalRow(
                  'VAT (${trimmedAmount(details.vatPercent)}%)',
                  formatAud(totals.vatAmount),
                  fonts,
                ),
                _totalRow(
                  'Discount',
                  '-${formatAud(totals.discountAmount)}',
                  fonts,
                ),
                pw.Divider(color: AppPdfPallete.border),
                _totalRow(
                  'Total',
                  formatAud(totals.totalAmount),
                  fonts,
                  bold: true,
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 32),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pdfSectionHeading('PAYMENT DETAILS', fonts),
                  pw.Text(
                    'BSB: $kBankBsb',
                    style: pw.TextStyle(font: fonts.regular, fontSize: 10),
                  ),
                  pw.Text(
                    'Account Number: $kBankAccountNumber',
                    style: pw.TextStyle(font: fonts.regular, fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pdfSectionHeading('TERMS & CONDITIONS', fonts),
                  pw.Text(
                    details.paymentTerms.isEmpty
                        ? '-'
                        : details.paymentTerms,
                    style: pw.TextStyle(font: fonts.regular, fontSize: 10),
                  ),
                ],
              ),
            ),
            invoiceIdQrCode(details.invoiceId, size: 64),
          ],
        ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _metaRow(String label, String value, AppPdfFonts fonts) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 10,
            color: AppPdfPallete.textSecondary,
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: 10,
            color: AppPdfPallete.textPrimary,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _totalRow(
  String label,
  String value,
  AppPdfFonts fonts, {
  bool bold = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: bold ? fonts.bold : fonts.regular,
            fontSize: bold ? 12 : 10,
            color: AppPdfPallete.textPrimary,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: bold ? fonts.bold : fonts.regular,
            fontSize: bold ? 12 : 10,
            color: AppPdfPallete.textPrimary,
          ),
        ),
      ],
    ),
  );
}
