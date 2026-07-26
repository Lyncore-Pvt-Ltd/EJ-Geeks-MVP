import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:ej_geek/core/di/service_locator.dart';
import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/inspection/presentation/bloc/inspection_bloc.dart';
import 'package:ej_geek/features/inspection/presentation/bloc/inspection_state.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_state.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/inspection_tab.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/invoice_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class InvoiceBottomSheet extends StatefulWidget {
  InvoiceBottomSheet({super.key, String? invoiceId})
    : invoiceId = invoiceId ?? const Uuid().v4();

  /// Ties this invoice's inspection, images and (later) PDF together under
  /// one id. Reused when reopening an existing invoice's card; otherwise a
  /// fresh id is minted for a brand new invoice.
  final String invoiceId;

  static Future<void> show(BuildContext context, {String? invoiceId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: InvoiceBottomSheet(invoiceId: invoiceId),
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

  void _onClosePressed() {
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
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.of(context).pop();
      });
    } else if (hasError) {
      setState(() => _isClosing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider<InspectionBloc>(
          create: (_) => sl<InspectionBloc>(param1: widget.invoiceId),
        ),
        BlocProvider<InvoiceDetailsBloc>(
          create: (_) => sl<InvoiceDetailsBloc>(param1: widget.invoiceId),
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
        ],
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppPallete.forgedSteel
                        : AppPallete.nebulousWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invoice',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppPallete.cascadingWhite
                              : AppPallete.tricornBlack,
                        ),
                      ),
                      _HeaderActions(
                        isDark: isDark,
                        isClosing: _isClosing,
                        activeTabIndex: _tabController.index,
                        onSavePressed: _onSavePressed,
                        onClosePressed: _onClosePressed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SegmentedTabControl(
                    controller: _tabController,
                    height: 40,
                    squeezeIntensity: 2,
                    tabTextColor: isDark
                        ? AppPallete.cascadingWhite
                        : AppPallete.tricornBlack,
                    selectedTabTextColor: AppPallete.whiteColor,
                    tabPadding: const EdgeInsets.symmetric(horizontal: 5),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    barDecoration: BoxDecoration(
                      color: isDark
                          ? AppPallete.warmOnyx
                          : AppPallete.nebulousWhite,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    indicatorDecoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF3D3D),
                          Color(0xFFFF6060),
                          Color(0xFFFF8A80),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    tabs: const [
                      SegmentTab(label: 'Inspection'),
                      SegmentTab(label: 'Invoice'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      InspectionTab(
                        key: _inspectionKey,
                        invoiceId: widget.invoiceId,
                      ),
                      InvoiceTab(key: _invoiceKey, invoiceId: widget.invoiceId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.isDark,
    required this.isClosing,
    required this.activeTabIndex,
    required this.onSavePressed,
    required this.onClosePressed,
  });

  final bool isDark;
  final bool isClosing;
  final int activeTabIndex;
  final VoidCallback onSavePressed;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    return activeTabIndex == 0
        ? BlocBuilder<InspectionBloc, InspectionState>(
            builder: (context, state) => _buildButtons(
              isSaving: state.isSaving,
              saveSuccess: state.saveSuccess,
            ),
          )
        : BlocBuilder<InvoiceDetailsBloc, InvoiceDetailsState>(
            builder: (context, state) => _buildButtons(
              isSaving: state.isSaving,
              saveSuccess: state.saveSuccess,
            ),
          );
  }

  Widget _buildButtons({required bool isSaving, required bool saveSuccess}) {
    final iconColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;

    final saveButton = IconButton(
      icon: isSaving && !isClosing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor,
              ),
            )
          : Icon(Icons.save, color: iconColor),
      onPressed: isSaving ? null : onSavePressed,
    );

    final Widget closeIcon;
    if (isClosing && isSaving) {
      closeIcon = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: iconColor),
      );
    } else if (isClosing && saveSuccess) {
      closeIcon = const Icon(Icons.check, color: Colors.green);
    } else {
      closeIcon = Icon(Icons.close, color: iconColor);
    }

    final closeButton = IconButton(
      icon: closeIcon,
      onPressed: isClosing ? null : onClosePressed,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [saveButton, closeButton],
    );
  }
}
