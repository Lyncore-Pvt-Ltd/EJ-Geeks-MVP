import 'package:auto_flow/core/presentation/widget/confirm_dialog.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_primary_button.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_secondary_button.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/inspection/domain/entities/vehicle_details.dart';
import 'package:auto_flow/features/inspection/presentation/bloc/inspection_bloc.dart';
import 'package:auto_flow/features/inspection/presentation/bloc/inspection_state.dart';
import 'package:auto_flow/features/inspection/presentation/widgets/inspection_text_field.dart';
import 'package:auto_flow/features/invoice/data/constants/invoice_number_formatter.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_line_item.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_totals.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_bloc.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_event.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_details_state.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/edit_line_item_dialog.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/invoice_date_picker_field.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/invoice_line_item_card.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/invoice_page_dots.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/line_item_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceTab extends StatefulWidget {
  const InvoiceTab({
    super.key,
    required this.invoiceId,
    required this.onGenerateRequested,
  });

  final String invoiceId;

  /// Triggered by the "Generate Invoice" button; owned by `InvoiceBottomSheet`
  /// so it can orchestrate saving both tabs before generating both PDFs.
  final VoidCallback onGenerateRequested;

  @override
  State<InvoiceTab> createState() => InvoiceTabState();
}

class InvoiceTabState extends State<InvoiceTab>
    with AutomaticKeepAliveClientMixin<InvoiceTab> {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();

  final _paymentTermsController = TextEditingController();
  final _appOwnerAddressController = TextEditingController();
  final _notesController = TextEditingController();
  final _gstController = TextEditingController();
  final _discountController = TextEditingController();

  final _itemNameController = TextEditingController();
  final _itemQtyController = TextEditingController(text: '1');
  final _itemPriceController = TextEditingController(text: '0.00');

  final _pageController = PageController(viewportFraction: 0.88);

  bool _isOwnerAddressLocked = false;
  bool _isPaymentTermsLocked = false;
  bool _hasLoadedOnce = false;
  bool _didSeedFromCurrentState = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The Invoice tab is built lazily inside the bottom sheet's TabBarView,
    // so by the time it mounts, InvoiceDetailsBloc's initial load may have
    // already finished — the load-complete BlocListener below only reacts
    // to the isLoading true→false *transition*, which it would then have
    // missed entirely. Seed directly from whatever the bloc's state already
    // is right now, once, so a tab built after loading finishes still
    // populates and unlocks correctly.
    if (!_didSeedFromCurrentState) {
      _didSeedFromCurrentState = true;
      final state = context.read<InvoiceDetailsBloc>().state;
      if (!state.isLoading) {
        _paymentTermsController.text = state.paymentTerms;
        _appOwnerAddressController.text = state.appOwnerAddress;
        _notesController.text = state.notes;
        _gstController.text = state.gstPercent == 0
            ? ''
            : _trimmed(state.gstPercent);
        _discountController.text = state.discountPercent == 0
            ? ''
            : _trimmed(state.discountPercent);
        _isOwnerAddressLocked = state.appOwnerAddressIsSaved;
        _isPaymentTermsLocked = state.paymentTermsIsSaved;
        _hasLoadedOnce = true;
      }
    }
  }

  @override
  void dispose() {
    _paymentTermsController.dispose();
    _appOwnerAddressController.dispose();
    _notesController.dispose();
    _gstController.dispose();
    _discountController.dispose();
    _itemNameController.dispose();
    _itemQtyController.dispose();
    _itemPriceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _addItem(BuildContext context) {
    context.read<InvoiceDetailsBloc>().add(
      LineItemAdded(
        name: _itemNameController.text,
        quantityRaw: _itemQtyController.text,
        unitPriceRaw: _itemPriceController.text,
      ),
    );
    _itemNameController.clear();
    _itemQtyController.text = '1';
    _itemPriceController.text = '0.00';
  }

  bool validate() => _formKey.currentState?.validate() ?? true;

  Future<void> _confirmFieldAction(
    String fieldLabel,
    String actionVerb,
    VoidCallback onConfirmed,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: actionVerb == 'save' ? 'Save $fieldLabel?' : 'Edit $fieldLabel?',
        message: actionVerb == 'save'
            ? 'Save this $fieldLabel and lock it from further edits?'
            : 'You already saved this $fieldLabel. Do you want to change it?',
      ),
    );
    if (confirmed == true) onConfirmed();
  }

  void save() {
    context.read<InvoiceDetailsBloc>().add(
      InvoiceDetailsSaved(
        paymentTerms: _paymentTermsController.text,
        notes: _notesController.text,
      ),
    );
  }

  void _saveAndLockOwnerAddress() =>
      _confirmFieldAction('App Owner Address', 'save', save);

  void _saveAndLockPaymentTerms() =>
      _confirmFieldAction('Payment Terms', 'save', save);

  void generate() {
    context.read<InvoiceDetailsBloc>().add(
      InvoiceGenerateRequested(
        paymentTerms: _paymentTermsController.text,
        notes: _notesController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<InvoiceDetailsBloc, InvoiceDetailsState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.saveSuccess != current.saveSuccess ||
              previous.sendSuccess != current.sendSuccess,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
            // Save success shows in the sheet's AfSaveStatus pill.
            if (state.saveSuccess || state.sendSuccess) {
              setState(() {
                if (_appOwnerAddressController.text.trim().isNotEmpty) {
                  _isOwnerAddressLocked = true;
                }
                if (_paymentTermsController.text.trim().isNotEmpty) {
                  _isPaymentTermsLocked = true;
                }
              });
            }
          },
        ),
        BlocListener<InvoiceDetailsBloc, InvoiceDetailsState>(
          listenWhen: (previous, current) =>
              previous.isLoading && !current.isLoading,
          listener: (context, state) {
            setState(() {
              _paymentTermsController.text = state.paymentTerms;
              _appOwnerAddressController.text = state.appOwnerAddress;
              _notesController.text = state.notes;
              _gstController.text = state.gstPercent == 0
                  ? ''
                  : _trimmed(state.gstPercent);
              _discountController.text = state.discountPercent == 0
                  ? ''
                  : _trimmed(state.discountPercent);
              _isOwnerAddressLocked = state.appOwnerAddressIsSaved;
              _isPaymentTermsLocked = state.paymentTermsIsSaved;
              _hasLoadedOnce = true;
            });
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AfSpace.gutter),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InvoiceNumberHeading(invoiceId: widget.invoiceId),
                        const SizedBox(height: AfSpace.m16),
                        const _RecipientCard(),
                        const SizedBox(height: AfSpace.m16),
                        InspectionTextField(
                          controller: _appOwnerAddressController,
                          label: 'App Owner Address',
                          onChanged: (value) => context
                              .read<InvoiceDetailsBloc>()
                              .add(AppOwnerAddressChanged(value)),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                          readOnly: !_hasLoadedOnce || _isOwnerAddressLocked,
                          onEditTap: _isOwnerAddressLocked
                              ? () => _confirmFieldAction(
                                  'App Owner Address',
                                  'edit',
                                  () => setState(
                                    () => _isOwnerAddressLocked = false,
                                  ),
                                )
                              : null,
                          onSaveTap: _isOwnerAddressLocked
                              ? null
                              : _saveAndLockOwnerAddress,
                        ),
                        const SizedBox(height: AfSpace.m16),
                        Row(
                          children: [
                            Expanded(
                              child:
                                  BlocSelector<
                                    InvoiceDetailsBloc,
                                    InvoiceDetailsState,
                                    DateTime?
                                  >(
                                    selector: (state) => state.issueDate,
                                    builder: (context, issueDate) {
                                      return InvoiceDatePickerField(
                                        label: 'Issue Date',
                                        date: issueDate,
                                        onPicked: (date) => context
                                            .read<InvoiceDetailsBloc>()
                                            .add(IssueDateChanged(date)),
                                      );
                                    },
                                  ),
                            ),
                            const SizedBox(width: AfSpace.s12),
                            Expanded(
                              child:
                                  BlocSelector<
                                    InvoiceDetailsBloc,
                                    InvoiceDetailsState,
                                    DateTime?
                                  >(
                                    selector: (state) => state.dueDate,
                                    builder: (context, dueDate) {
                                      return InvoiceDatePickerField(
                                        label: 'Due Date',
                                        date: dueDate,
                                        onPicked: (date) => context
                                            .read<InvoiceDetailsBloc>()
                                            .add(DueDateChanged(date)),
                                      );
                                    },
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AfSpace.m16),
                        InspectionTextField(
                          controller: _paymentTermsController,
                          label: 'Payment Terms',
                          growable: true,
                          readOnly: !_hasLoadedOnce || _isPaymentTermsLocked,
                          onEditTap: _isPaymentTermsLocked
                              ? () => _confirmFieldAction(
                                  'Payment Terms',
                                  'edit',
                                  () => setState(
                                    () => _isPaymentTermsLocked = false,
                                  ),
                                )
                              : null,
                          onSaveTap: _isPaymentTermsLocked
                              ? null
                              : _saveAndLockPaymentTerms,
                        ),
                        const SizedBox(height: AfSpace.l24),
                        _ItemAddForm(
                          nameController: _itemNameController,
                          qtyController: _itemQtyController,
                          priceController: _itemPriceController,
                          onAdd: () => _addItem(context),
                        ),
                        const SizedBox(height: AfSpace.l24),
                        BlocSelector<
                          InvoiceDetailsBloc,
                          InvoiceDetailsState,
                          List<InvoiceLineItem>
                        >(
                          selector: (state) => state.items,
                          builder: (context, items) {
                            return _LineItemsCarousel(
                              items: items,
                              pageController: _pageController,
                              onEdit: (item) =>
                                  EditLineItemDialog.show(context, item),
                              onRemove: (id) => context
                                  .read<InvoiceDetailsBloc>()
                                  .add(LineItemRemoved(id)),
                            );
                          },
                        ),
                        const SizedBox(height: AfSpace.l24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: InspectionTextField(
                                controller: _gstController,
                                label: 'GST %',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                                onChanged: (value) => context
                                    .read<InvoiceDetailsBloc>()
                                    .add(GstPercentChanged(value)),
                              ),
                            ),
                            const SizedBox(width: AfSpace.s12),
                            Expanded(
                              child: InspectionTextField(
                                controller: _discountController,
                                label: 'Discount %',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                                onChanged: (value) => context
                                    .read<InvoiceDetailsBloc>()
                                    .add(DiscountPercentChanged(value)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AfSpace.m16),
                        const _TotalsSummary(),
                        const SizedBox(height: AfSpace.m16),
                        InspectionTextField(
                          controller: _notesController,
                          label: 'Notes',
                          growable: true,
                        ),
                        const SizedBox(height: AfSpace.l24),
                        BlocBuilder<InvoiceDetailsBloc, InvoiceDetailsState>(
                          buildWhen: (previous, current) =>
                              previous.isSaving != current.isSaving ||
                              previous.isSending != current.isSending ||
                              previous.isLoading != current.isLoading,
                          builder: (context, state) {
                            final inspectionLoading = context
                                .select<InspectionBloc, bool>(
                                  (bloc) => bloc.state.isLoading,
                                );
                            final isBusy =
                                state.isSaving ||
                                state.isSending ||
                                state.isLoading ||
                                inspectionLoading;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AfPrimaryButton(
                                  label: 'Generate Invoice',
                                  busyLabel: 'Generating…',
                                  busy: state.isSending,
                                  onPressed: isBusy
                                      ? null
                                      : widget.onGenerateRequested,
                                ),
                                const SizedBox(height: AfSpace.s12),
                                AfSecondaryButton(
                                  label: 'Save invoice draft',
                                  busyLabel: 'Saving…',
                                  busy: state.isSaving,
                                  onPressed: isBusy ? null : save,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _trimmed(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

class _InvoiceNumberHeading extends StatelessWidget {
  const _InvoiceNumberHeading({required this.invoiceId});

  final String invoiceId;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice number',
          style: AutoFlowTokens.caption.copyWith(color: tokens.mute),
        ),
        const SizedBox(height: AfSpace.xs4),
        Text(
          formatInvoiceNumber(invoiceId),
          style: AutoFlowTokens.mono(fontSize: 17, color: tokens.ink),
        ),
      ],
    );
  }
}

/// Card spec from DESIGN.md: radius 16, 1px line border, card fill, card
/// elevation.
BoxDecoration _cardDecoration(AutoFlowTokens tokens) => BoxDecoration(
  color: tokens.card,
  borderRadius: AfRadius.cardAll,
  border: Border.all(color: tokens.line),
  boxShadow: AutoFlowTokens.cardShadow,
);

class _RecipientCard extends StatelessWidget {
  const _RecipientCard();

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    return BlocSelector<InspectionBloc, InspectionState, VehicleDetails?>(
      selector: (state) => state.vehicleDetails,
      builder: (context, vehicleDetails) {
        final ownerName = vehicleDetails?.ownerName ?? '';
        final address = vehicleDetails?.address ?? '';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AfSpace.m16),
          decoration: _cardDecoration(tokens),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipient',
                style: AutoFlowTokens.caption.copyWith(color: tokens.mute),
              ),
              const SizedBox(height: AfSpace.xs4),
              Text(
                ownerName.isEmpty ? 'Unnamed Owner' : ownerName,
                style: AutoFlowTokens.title.copyWith(color: tokens.ink),
              ),
              if (address.isNotEmpty) ...[
                const SizedBox(height: AfSpace.xs4),
                Text(
                  address,
                  style: AutoFlowTokens.caption.copyWith(color: tokens.mute2),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ItemAddForm extends StatelessWidget {
  const _ItemAddForm({
    required this.nameController,
    required this.qtyController,
    required this.priceController,
    required this.onAdd,
  });

  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LineItemFormFields(
          nameController: nameController,
          qtyController: qtyController,
          priceController: priceController,
        ),
        const SizedBox(height: AfSpace.s12),
        AfSecondaryButton(
          label: 'Add more items',
          icon: Icons.add,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _LineItemsCarousel extends StatelessWidget {
  const _LineItemsCarousel({
    required this.items,
    required this.pageController,
    required this.onEdit,
    required this.onRemove,
  });

  final List<InvoiceLineItem> items;
  final PageController pageController;
  final ValueChanged<InvoiceLineItem> onEdit;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    if (items.isEmpty) {
      return Text(
        'No items added yet',
        style: AutoFlowTokens.caption.copyWith(color: tokens.mute),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Invoice details '),
                  TextSpan(
                    text: '${items.length}',
                    style: AutoFlowTokens.mono(color: tokens.mute),
                  ),
                ],
              ),
              style: AutoFlowTokens.title.copyWith(color: tokens.ink),
            ),
            InvoicePageDots(controller: pageController, count: items.length),
          ],
        ),
        const SizedBox(height: AfSpace.s8),
        SizedBox(
          height: 224,
          child: PageView.builder(
            controller: pageController,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InvoiceLineItemCard(
                item: item,
                onEdit: () => onEdit(item),
                onRemove: () => onRemove(item.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TotalsSummary extends StatelessWidget {
  const _TotalsSummary();

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    return BlocSelector<InvoiceDetailsBloc, InvoiceDetailsState, InvoiceTotals>(
      selector: (state) => state.totals,
      builder: (context, totals) {
        return Container(
          padding: const EdgeInsets.all(AfSpace.m16),
          decoration: _cardDecoration(tokens),
          child: Column(
            children: [
              _row(tokens, 'Net Total', totals.netTotal),
              const SizedBox(height: AfSpace.s8),
              _row(tokens, 'GST Amount', totals.gstAmount),
              const SizedBox(height: AfSpace.s8),
              _row(tokens, 'Discount Amount', totals.discountAmount),
              const SizedBox(height: AfSpace.s12),
              Divider(color: tokens.line, height: 1, thickness: 1),
              const SizedBox(height: AfSpace.s12),
              _row(tokens, 'Total Amount', totals.totalAmount, emphasis: true),
            ],
          ),
        );
      },
    );
  }

  Widget _row(
    AutoFlowTokens tokens,
    String label,
    double value, {
    bool emphasis = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: emphasis
              ? AutoFlowTokens.title.copyWith(color: tokens.ink)
              : AutoFlowTokens.caption.copyWith(color: tokens.mute),
        ),
        Text(
          formatAud(value),
          style: AutoFlowTokens.mono(
            fontSize: emphasis ? 17 : 13,
            color: tokens.ink,
          ),
        ),
      ],
    );
  }
}
