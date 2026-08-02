import 'package:ej_geek/core/presentation/widget/dashed_divider.dart';
import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_gradient_button.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_state.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shown the moment "Generate" is pressed (from either the Invoice or
/// Inspection tab): first tracks the real PDF-generation progress reported
/// by [InvoiceDetailsBloc] via an animated 0-100 bar, then reveals the
/// success content (total, client, QR, PDF links) once generation actually
/// completes. Styled as a torn-ticket receipt using the app's own palette.
///
/// Reads live state off [bloc] directly (via its stream/state getters)
/// rather than `context.read`/`BlocBuilder`, since `showDialog` pushes onto
/// the root `Navigator` and this widget's context sits outside the
/// `MultiBlocProvider` subtree that provides it.
class InvoiceSuccessDialog extends StatefulWidget {
  const InvoiceSuccessDialog({
    super.key,
    required this.bloc,
    required this.clientName,
    required this.invoiceId,
    required this.onDone,
    required this.onSendNew,
  });

  final InvoiceDetailsBloc bloc;
  final String clientName;
  final String invoiceId;
  final VoidCallback onDone;
  final VoidCallback onSendNew;

  @override
  State<InvoiceSuccessDialog> createState() => _InvoiceSuccessDialogState();
}

class _InvoiceSuccessDialogState extends State<InvoiceSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;
  bool _reachedComplete = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    );
    // Climb toward a ceiling while generation is still in flight — real
    // PDF-build time isn't known up front, so this stays honest instead of
    // claiming a false 100% before the work is actually done.
    _progressController.animateTo(0.85);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _completeProgress() {
    if (_reachedComplete) return;
    _reachedComplete = true;
    _progressController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

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

    return StreamBuilder<InvoiceDetailsState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (!state.isSending && state.sendSuccess) {
          _completeProgress();
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              color: backdropColor,
              borderRadius: BorderRadius.circular(20),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, _) {
                  final progress = _progressAnimation.value;
                  final showContent =
                      state.sendSuccess && !state.isSending && progress >= 1.0;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: showContent
                        ? _SuccessContent(
                            key: const ValueKey('success'),
                            state: state,
                            clientName: widget.clientName,
                            invoiceId: widget.invoiceId,
                            textColor: textColor,
                            labelColor: labelColor,
                            dividerColor: dividerColor,
                            cardColor: cardColor,
                            onDone: widget.onDone,
                            onSendNew: widget.onSendNew,
                          )
                        : _GenerationProgressContent(
                            key: const ValueKey('progress'),
                            progress: progress,
                            textColor: textColor,
                            labelColor: labelColor,
                            dividerColor: dividerColor,
                            cardColor: cardColor,
                          ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GenerationProgressContent extends StatelessWidget {
  const _GenerationProgressContent({
    super.key,
    required this.progress,
    required this.textColor,
    required this.labelColor,
    required this.dividerColor,
    required this.cardColor,
  });

  final double progress;
  final Color textColor;
  final Color labelColor;
  final Color dividerColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Generating your invoice',
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
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
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
                    Icons.picture_as_pdf_outlined,
                    color: AppPallete.whiteColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please wait while we generate your job PDFs',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: labelColor),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 10,
                    child: Stack(
                      children: [
                        Container(color: dividerColor),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppPallete.selectionGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    super.key,
    required this.state,
    required this.clientName,
    required this.invoiceId,
    required this.textColor,
    required this.labelColor,
    required this.dividerColor,
    required this.cardColor,
    required this.onDone,
    required this.onSendNew,
  });

  final InvoiceDetailsState state;
  final String clientName;
  final String invoiceId;
  final Color textColor;
  final Color labelColor;
  final Color dividerColor;
  final Color cardColor;
  final VoidCallback onDone;
  final VoidCallback onSendNew;

  @override
  Widget build(BuildContext context) {
    final displayName = clientName.isEmpty ? 'Unnamed Owner' : clientName;
    final invoicePdfPath = state.invoicePdfPath;
    final inspectionPdfPath = state.inspectionPdfPath;

    return Column(
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
                  formatAud(state.totals.totalAmount),
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
                    color: dividerColor,
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
                            style: TextStyle(fontSize: 11, color: labelColor),
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
                    path: invoicePdfPath,
                    textColor: textColor,
                    borderColor: dividerColor,
                  ),
                  const SizedBox(height: 10),
                ],
                if (inspectionPdfPath != null) ...[
                  _OpenPdfButton(
                    label: 'Open Inspection PDF',
                    icon: Icons.fact_check_outlined,
                    path: inspectionPdfPath,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

/// Clips a row of evenly-spaced semicircular scallops along the top edge
/// and rounds the bottom two corners, giving a torn-ticket-stub look.
class _ScallopedTopClipper extends CustomClipper<Path> {
  const _ScallopedTopClipper();

  static const double _scallopWidth = 18;
  static const double _bottomRadius = 16;

  @override
  Path getClip(Size size) {
    final count = (size.width / _scallopWidth).round().clamp(4, 200);
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
      ..lineTo(size.width, size.height - _bottomRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - _bottomRadius,
        size.height,
      )
      ..lineTo(_bottomRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - _bottomRadius)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
