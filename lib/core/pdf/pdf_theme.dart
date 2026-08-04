import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' show Font;
import 'package:printing/printing.dart';

/// PDF-specific color palette mirroring `AppPallete`'s light theme (PDFs are
/// printed/viewed on a light background regardless of the app's theme mode)
/// plus its red-coral accent gradient, translated to `PdfColor` since the
/// `pdf` package doesn't understand Flutter `Color`.
class AppPdfPallete {
  static const PdfColor textPrimary = PdfColor.fromInt(0xFF2f2f2f); // tricornBlack
  static const PdfColor textSecondary = PdfColor.fromInt(0xFF677782); // hypnotic
  static const PdfColor border = PdfColor.fromInt(0xFFdddfdd); // nebulousWhite
  static const PdfColor background = PdfColor.fromInt(0xFFfbfbfb); // whiteout
  static const PdfColor accent = PdfColor.fromInt(0xFFFF3D3D); // selectionGradient start
  static const PdfColor white = PdfColors.white;
  static const PdfColor paidBlue = PdfColor.fromInt(0xFF14305C);
}

/// Loads the Inter font family (matching `FontFamily.inter` used across the
/// app) for use in PDF documents. Cache the result per document build.
class AppPdfFonts {
  final Font regular;
  final Font bold;

  const AppPdfFonts({required this.regular, required this.bold});

  static Future<AppPdfFonts> load() async {
    final regular = await PdfGoogleFonts.interRegular();
    final bold = await PdfGoogleFonts.interBold();
    return AppPdfFonts(regular: regular, bold: bold);
  }
}
