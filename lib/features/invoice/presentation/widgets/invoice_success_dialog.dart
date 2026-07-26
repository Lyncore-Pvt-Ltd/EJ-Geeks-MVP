import 'package:ej_geek/core/presentation/widget/dashed_divider.dart';
import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_gradient_button.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shown after a successful "Generate" (from either the Invoice or
/// Inspection tab): confirms the invoice total, client, and gives access to
/// both generated PDFs plus a QR code encoding the invoice id (a hook for a
/// future in-app scan-to-lookup feature). Styled as a torn-ticket receipt
/// using the app's own palette.
class InvoiceSuccessDialog extends StatelessWidget {
  const InvoiceSuccessDialog({
    super.key,
    required this.totalAmount,
    required this.clientName,
    required this.invoiceId,
    required this.invoicePdfPath,
    required this.inspectionPdfPath,
    required this.onDone,
    required this.onSendNew,
  });

  final double totalAmount;
  final String clientName;
  final String invoiceId;
  final String? invoicePdfPath;
  final String? inspectionPdfPath;
  final VoidCallback onDone;
  final VoidCallback onSendNew;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final labelColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;
    final dividerColor = isDark
        ? AppPallete.warmOnyx
        : AppPallete.nebulousWhite;
    final cardColor = isDark ? AppPallete.dynamicBlack : AppPallete.whiteout;
    final backdropColor = isDark
        ? AppPallete.warmOnyx
        : AppPallete.selectionGradient[0].withValues(alpha: 0.12);
    final displayName = clientName.isEmpty ? 'Unnamed Owner' : clientName;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        decoration: BoxDecoration(
          color: backdropColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PDF has been generated',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            ClipPath(
              clipper: const _ScallopedTopClipper(),
              child: Container(
                width: double.infinity,
                color: cardColor,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppPallete.selectionGradient,
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppPallete.whiteColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Invoice Success',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have successfully generated the job PDFs',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: labelColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Total Invoice',
                      style: TextStyle(fontSize: 12, color: labelColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatAud(totalAmount),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DashedDivider(color: dividerColor),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Client Destination',
                        style: TextStyle(fontSize: 12, color: labelColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppPallete.warmOnyx
                            : AppPallete.nebulousWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppPallete.selectionGradient[1],
                            child: Text(
                              displayName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppPallete.whiteColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ordered by',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: labelColor,
                                ),
                              ),
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DashedDivider(color: dividerColor),
                    const SizedBox(height: 16),
                    // TODO: future scan-to-lookup feature will decode this
                    // invoiceId QR to open the invoice directly — not
                    // implemented yet.
                    QrImageView(
                      data: invoiceId,
                      size: 140,
                      backgroundColor: AppPallete.whiteColor,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppPallete.tricornBlack,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppPallete.tricornBlack,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (invoicePdfPath != null) ...[
                      _OpenPdfButton(
                        label: 'Open Invoice PDF',
                        icon: Icons.receipt_long_outlined,
                        path: invoicePdfPath!,
                        textColor: textColor,
                        borderColor: dividerColor,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (inspectionPdfPath != null) ...[
                      _OpenPdfButton(
                        label: 'Open Inspection PDF',
                        icon: Icons.fact_check_outlined,
                        path: inspectionPdfPath!,
                        textColor: textColor,
                        borderColor: dividerColor,
                      ),
                      const SizedBox(height: 12),
                    ],
                    InspectionGradientButton(label: 'Done', onTap: onDone),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onSendNew,
                      child: Text(
                        'Send new invoice',
                        style: TextStyle(color: labelColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenPdfButton extends StatelessWidget {
  const _OpenPdfButton({
    required this.label,
    required this.icon,
    required this.path,
    required this.textColor,
    required this.borderColor,
  });

  final String label;
  final IconData icon;
  final String path;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => OpenFilex.open(path),
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// Clips a row of evenly-spaced semicircular scallops along the top edge
/// and rounds the bottom two corners, giving a torn-ticket-stub look.
class _ScallopedTopClipper extends CustomClipper<Path> {
  const _ScallopedTopClipper({this.scallopWidth = 18, this.bottomRadius = 16});

  final double scallopWidth;
  final double bottomRadius;

  @override
  Path getClip(Size size) {
    final count = (size.width / scallopWidth).round().clamp(4, 200);
    final w = size.width / count;
    final path = Path()..moveTo(0, w / 2);

    for (var i = 0; i < count; i++) {
      final endX = (i + 1) * w;
      path.arcToPoint(
        Offset(endX, w / 2),
        radius: Radius.circular(w / 2),
        clockwise: true,
      );
    }

    path
      ..lineTo(size.width, size.height - bottomRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - bottomRadius,
        size.height,
      )
      ..lineTo(bottomRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - bottomRadius)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
