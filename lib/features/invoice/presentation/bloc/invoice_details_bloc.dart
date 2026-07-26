import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../inspection/domain/usecases/get_inspection_by_invoice_id.dart';
import '../../data/constants/invoice_owner_defaults.dart';
import '../../domain/entities/invoice_details.dart';
import '../../domain/entities/invoice_line_item.dart';
import '../../domain/entities/invoice_totals.dart';
import '../../domain/usecases/generate_invoice_pdfs.dart';
import '../../domain/usecases/get_invoice_details_by_invoice_id.dart';
import '../../domain/usecases/save_invoice_details.dart';
import '../../domain/usecases/upsert_invoice_draft.dart';
import 'invoice_details_event.dart';
import 'invoice_details_state.dart';

class InvoiceDetailsBloc
    extends Bloc<InvoiceDetailsEvent, InvoiceDetailsState> {
  final String invoiceId;

  /// The invoice's creation date — used to key on-disk storage for the
  /// generated PDFs (`AppStoragePaths`).
  final DateTime invoiceCreatedAt;
  final SaveInvoiceDetails _saveInvoiceDetails;
  final GetInvoiceDetailsByInvoiceId _getInvoiceDetailsByInvoiceId;
  final GetInspectionByInvoiceId _getInspectionByInvoiceId;
  final UpsertInvoiceDraft _upsertInvoiceDraft;
  final GenerateInvoicePdfs _generateInvoicePdfs;

  InvoiceDetailsBloc({
    required this.invoiceId,
    required this.invoiceCreatedAt,
    required SaveInvoiceDetails saveInvoiceDetails,
    required GetInvoiceDetailsByInvoiceId getInvoiceDetailsByInvoiceId,
    required GetInspectionByInvoiceId getInspectionByInvoiceId,
    required UpsertInvoiceDraft upsertInvoiceDraft,
    required GenerateInvoicePdfs generateInvoicePdfs,
  }) : _saveInvoiceDetails = saveInvoiceDetails,
       _getInvoiceDetailsByInvoiceId = getInvoiceDetailsByInvoiceId,
       _getInspectionByInvoiceId = getInspectionByInvoiceId,
       _upsertInvoiceDraft = upsertInvoiceDraft,
       _generateInvoicePdfs = generateInvoicePdfs,
       super(const InvoiceDetailsState()) {
    on<InvoiceDetailsLoadRequested>(_onLoadRequested);
    on<IssueDateChanged>(_onIssueDateChanged);
    on<DueDateChanged>(_onDueDateChanged);
    on<LineItemAdded>(_onLineItemAdded);
    on<LineItemEdited>(_onLineItemEdited);
    on<LineItemRemoved>(_onLineItemRemoved);
    on<VatPercentChanged>(_onVatPercentChanged);
    on<DiscountPercentChanged>(_onDiscountPercentChanged);
    on<AppOwnerAddressChanged>(_onAppOwnerAddressChanged);
    on<InvoiceDetailsSaved>(_onSaved);
    on<InvoiceGenerateRequested>(_onGenerateRequested);
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

    final items = bundle?.items ?? const <InvoiceLineItem>[];
    final vatPercent = bundle?.details.vatPercent ?? 0;
    final discountPercent = bundle?.details.discountPercent ?? 0;

    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: detailsError ?? inspectionError,
        issueDate: bundle?.details.issueDate ?? DateTime.now(),
        dueDate: bundle?.details.dueDate,
        paymentTerms: bundle?.details.paymentTerms ?? '',
        notes: bundle?.details.notes ?? '',
        vatPercent: vatPercent,
        discountPercent: discountPercent,
        appOwnerAddress: bundle?.details.appOwnerAddress.isNotEmpty == true
            ? bundle!.details.appOwnerAddress
            : kDefaultAppOwnerAddress,
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

  void _onLineItemEdited(
    LineItemEdited event,
    Emitter<InvoiceDetailsState> emit,
  ) {
    final quantity = _parseOrZero(event.quantityRaw);
    final unitPrice = _parseOrZero(event.unitPriceRaw);
    if (event.name.trim().isEmpty || quantity <= 0 || unitPrice <= 0) {
      return;
    }

    final updatedItems = [
      for (final item in state.items)
        if (item.id == event.itemId)
          item.copyWith(
            name: event.name.trim(),
            quantity: quantity,
            unitPrice: unitPrice,
          )
        else
          item,
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

  void _onAppOwnerAddressChanged(
    AppOwnerAddressChanged event,
    Emitter<InvoiceDetailsState> emit,
  ) {
    emit(state.copyWith(appOwnerAddress: event.value));
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
      appOwnerAddress: state.appOwnerAddress,
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

  /// Ensures the progress dialog stays visible for at least this long,
  /// even if the save/PDF-build work underneath finishes almost instantly.
  static const _minGenerateDuration = Duration(milliseconds: 700);

  Future<void> _awaitMinDuration(DateTime start) async {
    final elapsed = DateTime.now().difference(start);
    if (elapsed < _minGenerateDuration) {
      await Future.delayed(_minGenerateDuration - elapsed);
    }
  }

  Future<void> _onGenerateRequested(
    InvoiceGenerateRequested event,
    Emitter<InvoiceDetailsState> emit,
  ) async {
    final start = DateTime.now();
    emit(
      state.copyWith(isSending: true, errorMessage: null, sendSuccess: false),
    );

    final draftResult = await _upsertInvoiceDraft(invoiceId);
    final draftError = draftResult.fold((f) => f.message, (_) => null);
    if (draftError != null) {
      await _awaitMinDuration(start);
      emit(state.copyWith(isSending: false, errorMessage: draftError));
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
      appOwnerAddress: state.appOwnerAddress,
    );

    final saveResult = await _saveInvoiceDetails(
      SaveInvoiceDetailsParams(details: details, items: state.items),
    );
    final saveError = saveResult.fold((f) => f.message, (_) => null);
    if (saveError != null) {
      await _awaitMinDuration(start);
      emit(state.copyWith(isSending: false, errorMessage: saveError));
      return;
    }

    final generateResult = await _generateInvoicePdfs(
      GenerateInvoicePdfsParams(
        invoiceId: invoiceId,
        invoiceCreatedAt: invoiceCreatedAt,
      ),
    );

    await _awaitMinDuration(start);

    generateResult.fold(
      (failure) => emit(
        state.copyWith(isSending: false, errorMessage: failure.message),
      ),
      (pdfs) => emit(
        state.copyWith(
          isSending: false,
          sendSuccess: true,
          paymentTerms: event.paymentTerms,
          notes: event.notes,
          invoicePdfPath: pdfs.invoicePdfPath,
          inspectionPdfPath: pdfs.inspectionPdfPath,
        ),
      ),
    );
  }
}
