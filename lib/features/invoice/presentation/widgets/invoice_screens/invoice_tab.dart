import 'package:ej_geek/core/presentation/widget/gradient_outline_button.dart';
import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/inspection/domain/entities/vehicle_details.dart';
import 'package:ej_geek/features/inspection/presentation/bloc/inspection_bloc.dart';
import 'package:ej_geek/features/inspection/presentation/bloc/inspection_state.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_gradient_button.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_text_field.dart';
import 'package:ej_geek/features/invoice/data/constants/invoice_number_formatter.dart';
import 'package:ej_geek/features/invoice/domain/entities/invoice_line_item.dart';
import 'package:ej_geek/features/invoice/domain/entities/invoice_totals.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_bloc.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_event.dart';
import 'package:ej_geek/features/invoice/presentation/bloc/invoice_details_state.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/currency_format.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/edit_line_item_dialog.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/invoice_date_picker_field.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/invoice_line_item_card.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/invoice_page_dots.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/line_item_form_fields.dart';
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
  final _vatController = TextEditingController();
  final _discountController = TextEditingController();

  final _itemNameController = TextEditingController();
  final _itemQtyController = TextEditingController();
  final _itemPriceController = TextEditingController();

  final _pageController = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _paymentTermsController.dispose();
    _appOwnerAddressController.dispose();
    _notesController.dispose();
    _vatController.dispose();
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
    _itemQtyController.clear();
    _itemPriceController.clear();
  }

  bool validate() => _formKey.currentState?.validate() ?? true;

  void save() {
    context.read<InvoiceDetailsBloc>().add(
      InvoiceDetailsSaved(
        paymentTerms: _paymentTermsController.text,
        notes: _notesController.text,
      ),
    );
  }

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
              previous.saveSuccess != current.saveSuccess,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            } else if (state.saveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice draft saved')),
              );
            }
          },
        ),
        BlocListener<InvoiceDetailsBloc, InvoiceDetailsState>(
          listenWhen: (previous, current) =>
              previous.isLoading && !current.isLoading,
          listener: (context, state) {
            _paymentTermsController.text = state.paymentTerms;
            _appOwnerAddressController.text = state.appOwnerAddress;
            _notesController.text = state.notes;
            _vatController.text = state.vatPercent == 0
                ? ''
                : _trimmed(state.vatPercent);
            _discountController.text = state.discountPercent == 0
                ? ''
                : _trimmed(state.discountPercent);
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InvoiceNumberHeading(invoiceId: widget.invoiceId),
                      const SizedBox(height: 16),
                      const _RecipientCard(),
                      const SizedBox(height: 16),
                      InspectionTextField(
                        controller: _appOwnerAddressController,
                        label: 'App Owner Address',
                        onChanged: (value) => context
                            .read<InvoiceDetailsBloc>()
                            .add(AppOwnerAddressChanged(value)),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
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
                          const SizedBox(width: 12),
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
                      const SizedBox(height: 16),
                      InspectionTextField(
                        controller: _paymentTermsController,
                        label: 'Payment Terms',
                      ),
                      const SizedBox(height: 20),
                      _ItemAddForm(
                        nameController: _itemNameController,
                        qtyController: _itemQtyController,
                        priceController: _itemPriceController,
                        onAdd: () => _addItem(context),
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: InspectionTextField(
                              controller: _vatController,
                              label: 'VAT %',
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
                                  .add(VatPercentChanged(value)),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                      const SizedBox(height: 16),
                      const _TotalsSummary(),
                      const SizedBox(height: 16),
                      InspectionTextField(
                        controller: _notesController,
                        label: 'Notes',
                        growable: true,
                      ),
                      const SizedBox(height: 20),
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
                            children: [
                              InspectionGradientButton(
                                label: 'Generate Invoice',
                                isLoading: state.isSending,
                                onTap: isBusy ? () {} : widget.onGenerateRequested,
                              ),
                              const SizedBox(height: 12),
                              GradientOutlineButton(
                                label: 'Save invoice draft',
                                onTap: isBusy ? () {} : save,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      formatInvoiceNumber(invoiceId),
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: isDark ? AppPallete.cascadingWhite : AppPallete.tricornBlack,
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final labelColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;
    final borderColor = isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite;

    return BlocSelector<InspectionBloc, InspectionState, VehicleDetails?>(
      selector: (state) => state.vehicleDetails,
      builder: (context, vehicleDetails) {
        final ownerName = vehicleDetails?.ownerName ?? '';
        final address = vehicleDetails?.address ?? '';
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipient',
                style: TextStyle(fontSize: 12, color: labelColor),
              ),
              const SizedBox(height: 4),
              Text(
                ownerName.isEmpty ? 'Unnamed Owner' : ownerName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(fontSize: 13, color: labelColor),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LineItemFormFields(
          nameController: nameController,
          qtyController: qtyController,
          priceController: priceController,
        ),
        const SizedBox(height: 10),
        GradientOutlineButton(label: 'Add more items', onTap: onAdd),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;

    if (items.isEmpty) {
      return Text(
        'No items added yet',
        style: TextStyle(fontSize: 13, color: labelColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Invoice details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            InvoicePageDots(controller: pageController, count: items.length),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final labelColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;
    final borderColor = isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite;

    return BlocSelector<InvoiceDetailsBloc, InvoiceDetailsState, InvoiceTotals>(
      selector: (state) => state.totals,
      builder: (context, totals) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _row('Net Total', totals.netTotal, labelColor, textColor),
              const SizedBox(height: 6),
              _row('VAT Amount', totals.vatAmount, labelColor, textColor),
              const SizedBox(height: 6),
              _row(
                'Discount Amount',
                totals.discountAmount,
                labelColor,
                textColor,
              ),
              const SizedBox(height: 10),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 10),
              _row(
                'Total Amount',
                totals.totalAmount,
                labelColor,
                textColor,
                bold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(
    String label,
    double value,
    Color labelColor,
    Color textColor, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? textColor : labelColor,
          ),
        ),
        Text(
          formatAud(value),
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
