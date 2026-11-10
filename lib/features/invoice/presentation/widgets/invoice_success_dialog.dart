import 'package:auto_flow/core/di/service_locator.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_pop_in.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_primary_button.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_secondary_button.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_spinner.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/invoice/domain/usecases/generate_combined_invoice_pdf.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_bloc.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_state.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shown the moment "Generate" is pressed (from either the Invoice or
/// Inspection tab): shows a spinner while [InvoiceDetailsBloc] builds the
/// PDFs, then reveals the success content (total, client, QR, PDF links) as
/// soon as generation actually completes — no decorative progress bar or
/// artificial wait.
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

class _InvoiceSuccessDialogState extends State<InvoiceSuccessDialog> {
  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    return StreamBuilder<InvoiceDetailsState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        final showContent = state.sendSuccess && !state.isSending;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AfSpace.gutter,
            vertical: AfSpace.l24,
          ),
          child: Container(
            padding: const EdgeInsets.all(AfSpace.l24),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: AfRadius.cardAll,
              border: Border.all(color: tokens.line),
              boxShadow: AutoFlowTokens.cardShadow,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: afDuration(context, 200),
                switchInCurve: AutoFlowTokens.easeOut,
                switchOutCurve: AutoFlowTokens.easeOut,
                child: showContent
                    ? _SuccessContent(
                        key: const ValueKey('success'),
                        state: state,
                        clientName: widget.clientName,
                        invoiceId: widget.invoiceId,
                        invoiceCreatedAt: widget.bloc.invoiceCreatedAt,
                        onDone: widget.onDone,
                        onSendNew: widget.onSendNew,
                      )
                    : const _GenerationProgressContent(
                        key: ValueKey('progress'),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GenerationProgressContent extends StatelessWidget {
  const _GenerationProgressContent({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Semantics(
      liveRegion: true,
      label: 'Generating your invoice',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AfSpace.s8),
          AfSpinner(
            size: 32,
            strokeWidth: 3,
            color: AutoFlowTokens.accent,
            track: tokens.line,
          ),
          const SizedBox(height: AfSpace.m16),
          Text(
            'Generating your invoice',
            textAlign: TextAlign.center,
            style: AutoFlowTokens.title.copyWith(color: tokens.ink),
          ),
          const SizedBox(height: AfSpace.xs4),
          Text(
            'Please wait while we generate your job PDFs',
            textAlign: TextAlign.center,
            style: AutoFlowTokens.caption.copyWith(color: tokens.mute2),
          ),
          const SizedBox(height: AfSpace.s8),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    super.key,
    required this.state,
    required this.clientName,
    required this.invoiceId,
    required this.invoiceCreatedAt,
    required this.onDone,
    required this.onSendNew,
  });

  final InvoiceDetailsState state;
  final String clientName;
  final String invoiceId;
  final DateTime invoiceCreatedAt;
  final VoidCallback onDone;
  final VoidCallback onSendNew;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final labelStyle = AutoFlowTokens.caption.copyWith(color: tokens.mute);
    final displayName = clientName.isEmpty ? 'Unnamed Owner' : clientName;
    final invoicePdfPath = state.invoicePdfPath;
    final inspectionPdfPath = state.inspectionPdfPath;
    Widget rule() => Divider(color: tokens.line, height: 1, thickness: 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AfPopIn(
          curve: AutoFlowTokens.easeOut,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AutoFlowTokens.successBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AutoFlowTokens.successFg,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: AfSpace.m16),
        Text(
          'PDF has been generated',
          textAlign: TextAlign.center,
          style: AutoFlowTokens.title.copyWith(color: tokens.ink),
        ),
        const SizedBox(height: AfSpace.xs4),
        Text(
          'You have successfully generated the job PDFs',
          textAlign: TextAlign.center,
          style: AutoFlowTokens.caption.copyWith(color: tokens.mute2),
        ),
        const SizedBox(height: AfSpace.l24),
        Text('Total Invoice', style: labelStyle),
        const SizedBox(height: AfSpace.xs4),
        Text(
          formatAud(state.totals.totalAmount),
          style: AutoFlowTokens.mono(fontSize: 28, color: tokens.ink),
        ),
        const SizedBox(height: AfSpace.m16),
        rule(),
        const SizedBox(height: AfSpace.m16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Client Destination', style: labelStyle),
        ),
        const SizedBox(height: AfSpace.s8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AfSpace.s12),
          decoration: BoxDecoration(
            color: tokens.soft,
            borderRadius: AfRadius.smallAll,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.navy,
                  borderRadius: AfRadius.smallAll,
                ),
                child: Text(
                  displayName.substring(0, 1).toUpperCase(),
                  style: AutoFlowTokens.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: AfSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ordered by', style: labelStyle),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AutoFlowTokens.body.copyWith(
                        color: tokens.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AfSpace.m16),
        rule(),
        const SizedBox(height: AfSpace.m16),
        // TODO: future scan-to-lookup feature will decode this
        // invoiceId QR to open the invoice directly — not
        // implemented yet.
        ClipRRect(
          borderRadius: AfRadius.smallAll,
          child: QrImageView(
            data: invoiceId,
            size: 140,
            // QR codes need a light ground to scan, in both themes.
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AutoFlowTokens.navyInk,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AutoFlowTokens.navyInk,
            ),
          ),
        ),
        const SizedBox(height: AfSpace.l24),
        if (invoicePdfPath != null) ...[
          AfSecondaryButton(
            label: 'Open Invoice PDF',
            icon: Icons.receipt_long_outlined,
            onPressed: () => OpenFilex.open(invoicePdfPath),
          ),
          const SizedBox(height: AfSpace.s8),
        ],
        if (inspectionPdfPath != null) ...[
          AfSecondaryButton(
            label: 'Open Inspection PDF',
            icon: Icons.fact_check_outlined,
            onPressed: () => OpenFilex.open(inspectionPdfPath),
          ),
          const SizedBox(height: AfSpace.s8),
        ],
        if (invoicePdfPath != null && inspectionPdfPath != null) ...[
          _CombinedPdfButton(
            invoiceId: invoiceId,
            invoiceCreatedAt: invoiceCreatedAt,
          ),
          const SizedBox(height: AfSpace.s8),
        ],
        const SizedBox(height: AfSpace.s8),
        AfPrimaryButton(label: 'Done', onPressed: onDone),
        const SizedBox(height: AfSpace.s8),
        Semantics(
          button: true,
          child: AfPressable(
            onTap: onSendNew,
            pressedScale: 0.96,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AfSpace.minTap),
              child: Center(
                child: Text(
                  'Send new invoice',
                  style: AutoFlowTokens.body.copyWith(
                    color: tokens.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Builds a single PDF (invoice pages then inspection pages, with the same
/// PAID stamp the individual invoice PDF shows) on demand and opens it —
/// unlike the plain open buttons this needs its own loading state since
/// building the combined file is an async operation rather than opening an
/// already-written path.
class _CombinedPdfButton extends StatefulWidget {
  const _CombinedPdfButton({
    required this.invoiceId,
    required this.invoiceCreatedAt,
  });

  final String invoiceId;
  final DateTime invoiceCreatedAt;

  @override
  State<_CombinedPdfButton> createState() => _CombinedPdfButtonState();
}

class _CombinedPdfButtonState extends State<_CombinedPdfButton> {
  bool _isLoading = false;

  Future<void> _onPressed() async {
    setState(() => _isLoading = true);
    final result = await sl<GenerateCombinedInvoicePdf>()(
      GenerateCombinedInvoicePdfParams(
        invoiceId: widget.invoiceId,
        invoiceCreatedAt: widget.invoiceCreatedAt,
      ),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (path) => OpenFilex.open(path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AfSecondaryButton(
      label: 'View Combined PDF',
      busyLabel: 'Building PDF…',
      icon: Icons.picture_as_pdf_outlined,
      busy: _isLoading,
      onPressed: _isLoading ? null : _onPressed,
    );
  }
}
