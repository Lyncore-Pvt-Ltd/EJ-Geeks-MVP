import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../inspection/domain/usecases/get_inspection_by_invoice_id.dart';
import '../../domain/entities/invoice_details.dart';
import '../../domain/entities/invoice_line_item.dart';
import '../../domain/entities/invoice_totals.dart';
import '../../domain/usecases/get_invoice_details_by_invoice_id.dart';
import '../../domain/usecases/save_invoice_details.dart';
import '../../domain/usecases/upsert_invoice_draft.dart';
import 'invoice_details_event.dart';
import 'invoice_details_state.dart';

class InvoiceDetailsBloc
    extends Bloc<InvoiceDetailsEvent, InvoiceDetailsState> {
  final String invoiceId;
  final SaveInvoiceDetails _saveInvoiceDetails;
  final GetInvoiceDetailsByInvoiceId _getInvoiceDetailsByInvoiceId;
  final GetInspectionByInvoiceId _getInspectionByInvoiceId;
  final UpsertInvoiceDraft _upsertInvoiceDraft;

  InvoiceDetailsBloc({
    required this.invoiceId,
    required SaveInvoiceDetails saveInvoiceDetails,
    required GetInvoiceDetailsByInvoiceId getInvoiceDetailsByInvoiceId,
    required GetInspectionByInvoiceId getInspectionByInvoiceId,
    required UpsertInvoiceDraft upsertInvoiceDraft,
  }) : _saveInvoiceDetails = saveInvoiceDetails,
       _getInvoiceDetailsByInvoiceId = getInvoiceDetailsByInvoiceId,
       _getInspectionByInvoiceId = getInspectionByInvoiceId,
       _upsertInvoiceDraft = upsertInvoiceDraft,
       super(const InvoiceDetailsState()) {
    on<InvoiceDetailsLoadRequested>(_onLoadRequested);
    on<IssueDateChanged>(_onIssueDateChanged);
    on<DueDateChanged>(_onDueDateChanged);
    on<LineItemAdded>(_onLineItemAdded);
    on<LineItemRemoved>(_onLineItemRemoved);
    on<VatPercentChanged>(_onVatPercentChanged);
    on<DiscountPercentChanged>(_onDiscountPercentChanged);
    on<InvoiceDetailsSaved>(_onSaved);
    add(const InvoiceDetailsLoadRequested());
  }

  double _parseOrZero(String raw) => double.tryParse(raw) ?? 0;

  Future<void> _onLoadRequested(
    InvoiceDetailsLoadRequested event,
    Emitter<InvoiceDetailsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final detailsResult = await _getInvoiceDetailsByInvoiceId(invoiceId);
    final inspectionResult = await _getInspectionByInvoiceId(invoiceId);

    final detailsError = detailsResult.fold((f) => f.message, (_) => null);
    final inspectionError = inspectionResult.fold(
      (f) => f.message,
      (_) => null,
    );

    final bundle = detailsResult.fold((_) => null, (bundle) => bundle);
    final inspection = inspectionResult.fold((_) => null, (record) => record);

    final items = bundle?.items ?? const <InvoiceLineItem>[];
    final vatPercent = bundle?.details.vatPercent ?? 0;
    final discountPercent = bundle?.details.discountPercent ?? 0;

    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: detailsError ?? inspectionError,
        ownerName: inspection?.vehicleDetails.ownerName ?? '',
        address: inspection?.vehicleDetails.address ?? '',
        issueDate: bundle?.details.issueDate ?? DateTime.now(),
        dueDate: bundle?.details.dueDate,
        paymentTerms: bundle?.details.paymentTerms ?? '',
        notes: bundle?.details.notes ?? '',
        vatPercent: vatPercent,
        discountPercent: discountPercent,
        items: items,
        totals: computeInvoiceTotals(items, vatPercent, discountPercent),
      ),
    );
  }

  void _onIssueDateChanged(
    IssueDateChanged event,
    Emitter<InvoiceDetailsState> emit,
  ) {
    emit(state.copyWith(issueDate: event.date));
  }

  void _onDueDateChanged(
    DueDateChanged event,
    Emitter<InvoiceDetailsState> emit,
  ) {
    emit(state.copyWith(dueDate: event.date));
  }

  void _onLineItemAdded(
    LineItemAdded event,
    Emitter<InvoiceDetailsState> emit,
  ) {
    final quantity = _parseOrZero(event.quantityRaw);
    final unitPrice = _parseOrZero(event.unitPriceRaw);
    if (event.name.trim().isEmpty || quantity <= 0 || unitPrice <= 0) {
      return;
    }

    final updatedItems = [
      ...state.items,
      InvoiceLineItem(
        id: const Uuid().v4(),
        name: event.name.trim(),
        quantity: quantity,
        unitPrice: unitPrice,
      ),
    ];

    emit(
      state.copyWith(
        items: updatedItems,
        totals: computeInvoiceTotals(
          updatedItems,
          state.vatPercent,
          state.discountPercent,
        ),
      ),
    );
  }

  void _onLineItemRemoved(
    LineItemRemoved event,
    Emitter<InvoiceDetailsState> emit,
  ) {
    final updatedItems = state.items
        .where((item) => item.id != event.itemId)
        .toList();

    emit(
      state.copyWith(
        items: updatedItems,
        totals: computeInvoiceTotals(
          updatedItems,
          state.vatPercent,
          state.discountPercent,
        ),
      ),
    );
  }

  void _onVatPercentChanged(
    VatPercentChanged event,
    Emitter<InvoiceDetailsState> emit,
  ) {
    final vatPercent = _parseOrZero(event.rawValue);
    emit(
      state.copyWith(
        vatPercent: vatPercent,
        totals: computeInvoiceTotals(
          state.items,
          vatPercent,
          state.discountPercent,
        ),
      ),
    );
  }

  void _onDiscountPercentChanged(
    DiscountPercentChanged event,
    Emitter<InvoiceDetailsState> emit,
  ) {
    final discountPercent = _parseOrZero(event.rawValue);
    emit(
      state.copyWith(
        discountPercent: discountPercent,
        totals: computeInvoiceTotals(
          state.items,
          state.vatPercent,
          discountPercent,
        ),
      ),
    );
  }

  Future<void> _onSaved(
    InvoiceDetailsSaved event,
    Emitter<InvoiceDetailsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));

    final draftResult = await _upsertInvoiceDraft(invoiceId);
    final draftError = draftResult.fold((f) => f.message, (_) => null);
    if (draftError != null) {
      emit(state.copyWith(isSaving: false, errorMessage: draftError));
      return;
    }

    final details = InvoiceDetails(
      invoiceId: invoiceId,
      issueDate: state.issueDate,
      dueDate: state.dueDate,
      paymentTerms: event.paymentTerms,
      notes: event.notes,
      vatPercent: state.vatPercent,
      discountPercent: state.discountPercent,
    );

    final result = await _saveInvoiceDetails(
      SaveInvoiceDetailsParams(details: details, items: state.items),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: failure.message),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
          paymentTerms: event.paymentTerms,
          notes: event.notes,
        ),
      ),
    );
  }
}
