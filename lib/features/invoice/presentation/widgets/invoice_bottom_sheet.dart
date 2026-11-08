import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:auto_flow/core/di/service_locator.dart';
import 'package:auto_flow/core/presentation/widget/confirm_dialog.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_spinner.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_save_status.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_toolbar_icon_button.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/inspection/presentation/bloc/inspection_bloc.dart';
import 'package:auto_flow/features/inspection/presentation/bloc/inspection_state.dart';
import 'package:auto_flow/features/invoice/domain/entities/payment_status.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_bloc.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_event.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_state.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_close_confirm.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/inspection_tab.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/invoice_tab.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class InvoiceBottomSheet extends StatefulWidget {
  InvoiceBottomSheet({
    super.key,
    String? invoiceId,
    DateTime? createdAt,
    this.autoGenerate = false,
  }) : invoiceId = invoiceId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Ties this invoice's inspection, images and (later) PDF together under
  /// one id. Reused when reopening an existing invoice's card; otherwise a
  /// fresh id is minted for a brand new invoice.
  final String invoiceId;

  /// The invoice's creation date, used to key its on-disk storage folder
  /// (`AppStoragePaths`). Reused from the persisted row when reopening an
  /// existing invoice; defaults to now for a brand new invoice.
  final DateTime createdAt;

  /// When true, fires the same flow as tapping the header's "Generate PDF"
  /// button once the sheet's initial load finishes, so quick-action entry
  /// points (e.g. `InvoiceCard`'s menu) can reuse the full generate flow
  /// (validation, save, regeneration confirmation, success dialog) without
  /// duplicating it.
  final bool autoGenerate;

  static Future<void> show(
    BuildContext context, {
    String? invoiceId,
    DateTime? createdAt,
    bool autoGenerate = false,
  }) {
    // Resolve once here rather than inside the widget constructor: the
    // modal route's builder can be re-invoked mid-session (e.g. when the
    // keyboard opens/closes changes MediaQuery), and re-resolving a null
    // invoiceId there would mint a fresh random uuid on every rebuild.
    final resolvedInvoiceId = invoiceId ?? const Uuid().v4();
    final resolvedCreatedAt = createdAt ?? DateTime.now();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AutoFlowTokens.scrim,
      sheetAnimationStyle: afSheetAnimation(context),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: InvoiceBottomSheet(
          invoiceId: resolvedInvoiceId,
          createdAt: resolvedCreatedAt,
          autoGenerate: autoGenerate,
        ),
      ),
    );
  }

  @override
  State<InvoiceBottomSheet> createState() => _InvoiceBottomSheetState();
}

class _InvoiceBottomSheetState extends State<InvoiceBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _inspectionKey = GlobalKey<InspectionTabState>();
  final _invoiceKey = GlobalKey<InvoiceTabState>();

  bool _isClosing = false;
  bool _popScheduled = false;
  bool _pendingGenerate = false;
  bool _autoGenerateTriggered = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {});
  }

  void _triggerActiveSave() {
    if (_tabController.index == 0) {
      _inspectionKey.currentState?.save();
    } else {
      _invoiceKey.currentState?.save();
    }
  }

  void _onSavePressed() {
    _triggerActiveSave();
  }

  /// Shared "Generate" entry point for both tabs: always saves the
  /// Inspection tab's current form data first, then (once that completes)
  /// triggers the Invoice tab's save + both-PDF generation.
  void _onGeneratePressed() {
    final inspectionValid = _inspectionKey.currentState?.validate() ?? true;
    final invoiceValid = _invoiceKey.currentState?.validate() ?? true;
    if (!inspectionValid) {
      _tabController.animateTo(0);
      return;
    }
    if (!invoiceValid) {
      _tabController.animateTo(1);
      return;
    }
    _pendingGenerate = true;
    _inspectionKey.currentState?.save();
  }

  /// Fires the generate flow once both blocs' initial load has finished,
  /// for sheets opened with `autoGenerate: true`. Guarded by
  /// `_autoGenerateTriggered` since either bloc's isLoading transition can
  /// call this and both may already be loaded by the time the second one
  /// finishes.
  void _maybeAutoGenerate(BuildContext context) {
    if (_autoGenerateTriggered) return;
    if (context.read<InspectionBloc>().state.isLoading) return;
    if (context.read<InvoiceDetailsBloc>().state.isLoading) return;
    _autoGenerateTriggered = true;
    _onGeneratePressed();
  }

  Future<void> _confirmRegeneration(BuildContext context) async {
    final invoiceDetailsBloc = context.read<InvoiceDetailsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        title: 'Changes Detected',
        message:
            'Changes have been made to the invoice and/or inspection. '
            'Generate a new PDF?',
        confirmLabel: 'Generate',
      ),
    );
    if (confirmed != true || !context.mounted) return;

    invoiceDetailsBloc.add(
      InvoiceGenerateRequested(
        paymentTerms: invoiceDetailsBloc.state.paymentTerms,
        notes: invoiceDetailsBloc.state.notes,
        forceRegenerate: true,
      ),
    );
  }

  Future<void> _onClosePressed(BuildContext context) async {
    final isDirty = _inspectionKey.currentState?.hasUnsavedChanges ?? false;
    if (!isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final confirmed = await confirmCloseInvoiceSheet(context);
    if (!context.mounted) return;
    if (!confirmed) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isClosing = true);
    _triggerActiveSave();
  }

  void _handleInspectionSaveState(InspectionState state) {
    if (_tabController.index != 0) return;
    _handleActiveSaveState(
      isSaving: state.isSaving,
      saveSuccess: state.saveSuccess,
      hasError: state.errorMessage != null,
    );
  }

  void _handleInvoiceSaveState(InvoiceDetailsState state) {
    if (_tabController.index != 1) return;
    _handleActiveSaveState(
      isSaving: state.isSaving,
      saveSuccess: state.saveSuccess,
      hasError: state.errorMessage != null,
    );
  }

  void _handleActiveSaveState({
    required bool isSaving,
    required bool saveSuccess,
    required bool hasError,
  }) {
    if (!_isClosing) return;
    if (isSaving) return;
    if (saveSuccess && !_popScheduled) {
      _popScheduled = true;
      // Close as soon as the save lands; the header's check icon is enough
      // feedback without holding the sheet open on a timer.
      Navigator.of(context).pop();
    } else if (hasError) {
      setState(() => _isClosing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<InspectionBloc>(
          create: (_) => sl<InspectionBloc>(
            param1: widget.invoiceId,
            param2: widget.createdAt,
          ),
        ),
        BlocProvider<InvoiceDetailsBloc>(
          create: (_) => sl<InvoiceDetailsBloc>(
            param1: widget.invoiceId,
            param2: widget.createdAt,
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<InspectionBloc, InspectionState>(
            listenWhen: (previous, current) =>
                previous.isSaving != current.isSaving ||
                previous.saveSuccess != current.saveSuccess ||
                previous.errorMessage != current.errorMessage,
            listener: (context, state) => _handleInspectionSaveState(state),
          ),
          BlocListener<InvoiceDetailsBloc, InvoiceDetailsState>(
            listenWhen: (previous, current) =>
                previous.isSaving != current.isSaving ||
                previous.saveSuccess != current.saveSuccess ||
                previous.errorMessage != current.errorMessage,
            listener: (context, state) => _handleInvoiceSaveState(state),
          ),
          BlocListener<InvoiceDetailsBloc, InvoiceDetailsState>(
            listenWhen: (previous, current) =>
                widget.autoGenerate &&
                !_autoGenerateTriggered &&
                previous.isLoading &&
                !current.isLoading,
            listener: (context, state) => _maybeAutoGenerate(context),
          ),
          BlocListener<InspectionBloc, InspectionState>(
            listenWhen: (previous, current) =>
                widget.autoGenerate &&
                !_autoGenerateTriggered &&
                previous.isLoading &&
                !current.isLoading,
            listener: (context, state) => _maybeAutoGenerate(context),
          ),
          BlocListener<InspectionBloc, InspectionState>(
            listenWhen: (previous, current) =>
                _pendingGenerate && previous.isSaving && !current.isSaving,
            listener: (context, state) {
              _pendingGenerate = false;
              if (state.errorMessage == null) {
                final invoiceTabState = _invoiceKey.currentState;
                if (invoiceTabState != null) {
                  invoiceTabState.generate();
                } else {
                  // The Invoice tab has never been built in this sheet
                  // session (TabBarView builds tabs lazily), so there's no
                  // unsaved edit to its Payment Terms/Notes fields to read —
                  // fall back to the bloc's own loaded values so Generate
                  // still fires instead of silently no-oping.
                  final invoiceDetailsBloc = context.read<InvoiceDetailsBloc>();
                  invoiceDetailsBloc.add(
                    InvoiceGenerateRequested(
                      paymentTerms: invoiceDetailsBloc.state.paymentTerms,
                      notes: invoiceDetailsBloc.state.notes,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
            },
          ),
          BlocListener<InvoiceDetailsBloc, InvoiceDetailsState>(
            listenWhen: (previous, current) =>
                previous.isSending != current.isSending,
            listener: (context, state) {
              if (state.isSending) {
                final invoiceDetailsBloc = context.read<InvoiceDetailsBloc>();
                final clientName =
                    context
                        .read<InspectionBloc>()
                        .state
                        .vehicleDetails
                        ?.ownerName ??
                    '';
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => InvoiceSuccessDialog(
                    bloc: invoiceDetailsBloc,
                    clientName: clientName,
                    invoiceId: invoiceDetailsBloc.invoiceId,
                    onDone: () {
                      Navigator.of(dialogContext).pop();
                    },
                    onSendNew: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                );
                return;
              }

              // isSending just flipped true -> false.
              if (state.needsRegenerationConfirmation) {
                // Nothing was generated — the dialog above is still on its
                // spinner; dismiss it and ask before rebuilding.
                Navigator.of(context).pop();
                _confirmRegeneration(context);
                return;
              }

              // On failure, dismiss the dialog opened above; the tab's own
              // errorMessage listener shows the SnackBar. On success, the
              // dialog is already open and swaps to its success content
              // as soon as it sees the now-ready state.
              if (!state.sendSuccess) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: AfRadius.sheetTop,
              border: Border(top: BorderSide(color: tokens.line)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: AfSpace.s12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.line,
                      borderRadius: AfRadius.chipAll,
                    ),
                  ),
                  const SizedBox(height: AfSpace.s12),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AfSpace.gutter,
                      right: AfSpace.s8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Invoice',
                            style: AutoFlowTokens.headline.copyWith(
                              color: tokens.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final isInitialLoading =
                                context.select<InspectionBloc, bool>(
                                  (bloc) => bloc.state.isLoading,
                                ) ||
                                context.select<InvoiceDetailsBloc, bool>(
                                  (bloc) => bloc.state.isLoading,
                                );
                            return _HeaderActions(
                              isClosing: _isClosing,
                              isInitialLoading: isInitialLoading,
                              activeTabIndex: _tabController.index,
                              onGeneratePressed: _onGeneratePressed,
                              onSavePressed: _onSavePressed,
                              onClosePressed: () => _onClosePressed(context),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AfSpace.s12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AfSpace.gutter,
                    ),
                    child: SegmentedTabControl(
                      controller: _tabController,
                      height: AfSpace.minTap,
                      squeezeIntensity: 2,
                      tabTextColor: tokens.ink,
                      selectedTabTextColor: tokens.card,
                      tabPadding: const EdgeInsets.symmetric(
                        horizontal: AfSpace.xs4,
                      ),
                      textStyle: AutoFlowTokens.caption.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      barDecoration: BoxDecoration(
                        color: tokens.soft,
                        borderRadius: AfRadius.controlAll,
                      ),
                      indicatorDecoration: BoxDecoration(
                        color: tokens.ink,
                        borderRadius: AfRadius.controlAll,
                      ),
                      tabs: const [
                        SegmentTab(label: 'Inspection'),
                        SegmentTab(label: 'Invoice'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AfSpace.s12),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              InspectionTab(
                                key: _inspectionKey,
                                invoiceId: widget.invoiceId,
                                onGenerateRequested: _onGeneratePressed,
                              ),
                              InvoiceTab(
                                key: _invoiceKey,
                                invoiceId: widget.invoiceId,
                                onGenerateRequested: _onGeneratePressed,
                              ),
                            ],
                          ),
                        ),
                        // "Saving… → Saved" for the active tab, floating so
                        // it's visible whichever control started the save
                        // (header Save, Draft, Generate).
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: AfSpace.m16,
                          child: IgnorePointer(
                            child: Center(
                              child: Builder(
                                builder: (context) {
                                  final (saving, succeeded) =
                                      _tabController.index == 0
                                      ? context.select<InspectionBloc,
                                            (bool, bool)>(
                                          (b) => (
                                            b.state.isSaving,
                                            b.state.saveSuccess,
                                          ),
                                        )
                                      : context.select<InvoiceDetailsBloc,
                                            (bool, bool)>(
                                          (b) => (
                                            b.state.isSaving,
                                            b.state.saveSuccess,
                                          ),
                                        );
                                  return AfSaveStatus(
                                    // A fresh pill per tab, so switching
                                    // tabs doesn't carry the other's state.
                                    key: ValueKey(_tabController.index),
                                    saving: saving,
                                    saveSucceeded: succeeded,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.isClosing,
    required this.isInitialLoading,
    required this.activeTabIndex,
    required this.onGeneratePressed,
    required this.onSavePressed,
    required this.onClosePressed,
  });

  final bool isClosing;
  final bool isInitialLoading;
  final int activeTabIndex;
  final VoidCallback onGeneratePressed;
  final VoidCallback onSavePressed;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceDetailsBloc, InvoiceDetailsState>(
      buildWhen: (previous, current) =>
          previous.paymentStatus != current.paymentStatus,
      builder: (context, detailsState) {
        final markPaidButton = _buildMarkPaidButton(
          context,
          detailsState.paymentStatus,
        );
        return activeTabIndex == 0
            ? BlocBuilder<InspectionBloc, InspectionState>(
                builder: (context, state) => _buildButtons(
                  context,
                  isSaving: state.isSaving,
                  saveSuccess: state.saveSuccess,
                  markPaidButton: markPaidButton,
                ),
              )
            : BlocBuilder<InvoiceDetailsBloc, InvoiceDetailsState>(
                builder: (context, state) => _buildButtons(
                  context,
                  isSaving: state.isSaving,
                  saveSuccess: state.saveSuccess,
                  markPaidButton: markPaidButton,
                ),
              );
      },
    );
  }

  Future<void> _confirmMarkPaid(
    BuildContext context,
    PaymentStatus paymentStatus,
  ) async {
    final invoiceDetailsBloc = context.read<InvoiceDetailsBloc>();
    final isPaid = paymentStatus == PaymentStatus.paid;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: isPaid ? 'Undo Payment' : 'Mark as Paid',
        message: isPaid
            ? 'Are you sure you want to undo the paid status for this invoice?'
            : 'Confirm this invoice has been paid? A paid date and time will be recorded.',
      ),
    );
    if (confirmed == true) {
      invoiceDetailsBloc.add(const PaymentStatusToggled());
    }
  }

  Widget _buildMarkPaidButton(BuildContext context, PaymentStatus status) {
    final iconColor = AutoFlowTokens.of(context).ink;
    final isPaid = status == PaymentStatus.paid;

    return AfToolbarIconButton(
      tooltip: isPaid ? 'Undo Payment' : 'Mark Paid',
      color: iconColor,
      icon: isPaid ? Icons.undo : Icons.attach_money,
      onPressed: isInitialLoading
          ? null
          : () => _confirmMarkPaid(context, status),
    );
  }

  Widget _buildButtons(
    BuildContext context, {
    required bool isSaving,
    required bool saveSuccess,
    required Widget markPaidButton,
  }) {
    final tokens = AutoFlowTokens.of(context);
    final iconColor = tokens.ink;
    final spinner = AfSpinner(
      key: const ValueKey('spinner'),
      size: 20,
      color: iconColor,
      track: tokens.line,
    );

    final generateButton = AfToolbarIconButton(
      tooltip: 'Generate PDF',
      color: iconColor,
      icon: Icons.picture_as_pdf_outlined,
      onPressed: isInitialLoading ? null : onGeneratePressed,
    );

    final saveButton = AfToolbarIconButton.custom(
      tooltip: isSaving && !isClosing ? 'Saving' : 'Save',
      color: iconColor,
      onPressed: (isSaving || isInitialLoading) ? null : onSavePressed,
      child: isSaving && !isClosing
          ? spinner
          : const Icon(Icons.save, key: ValueKey('save')),
    );

    final Widget closeIcon;
    final String closeTooltip;
    if (isClosing && isSaving) {
      closeIcon = spinner;
      closeTooltip = 'Saving before closing';
    } else if (isClosing && saveSuccess) {
      closeIcon = const Icon(
        Icons.check,
        key: ValueKey('saved'),
        color: AutoFlowTokens.successFg,
      );
      closeTooltip = 'Saved';
    } else {
      closeIcon = const Icon(Icons.close, key: ValueKey('close'));
      closeTooltip = 'Close';
    }

    final closeButton = AfToolbarIconButton.custom(
      tooltip: closeTooltip,
      color: iconColor,
      onPressed: (isClosing || isInitialLoading) ? null : onClosePressed,
      child: closeIcon,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [generateButton, markPaidButton, saveButton, closeButton],
    );
  }
}
