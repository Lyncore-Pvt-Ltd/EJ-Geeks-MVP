import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' show Font;
import 'package:printing/printing.dart';

/// PDF-specific color palette (PDFs are printed/viewed on a light background
/// regardless of the app's theme mode), translated to `PdfColor` since the
/// `pdf` package doesn't understand Flutter `Color`. These values are the
/// legacy pre-`AutoFlowTokens` palette, kept so generated PDFs look the same;
/// the app UI itself is themed via `AutoFlowTokens`.
class AppPdfPallete {
  static const PdfColor textPrimary = PdfColor.fromInt(
    0xFF2f2f2f,
  ); // tricornBlack
  static const PdfColor textSecondary = PdfColor.fromInt(
    0xFF677782,
  ); // hypnotic
  static const PdfColor border = PdfColor.fromInt(0xFFdddfdd); // nebulousWhite
  static const PdfColor background = PdfColor.fromInt(0xFFfbfbfb); // whiteout
  static const PdfColor accent = PdfColor.fromInt(
    0xFFFF3D3D,
  ); // selectionGradient start
  static const PdfColor white = PdfColors.white;
  static const PdfColor paidBlue = PdfColor.fromInt(0xFF14305C);
}

/// Loads the Inter font family for use in PDF documents (independent of the
/// app UI's Satoshi font from `AutoFlowTokens.fontFamily`). Cache the result
/// per document build.
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
