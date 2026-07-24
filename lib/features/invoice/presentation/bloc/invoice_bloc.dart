import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/service_status.dart';
import '../../domain/usecases/delete_invoice.dart';
import '../../domain/usecases/get_all_invoices.dart';
import '../../domain/usecases/update_invoice_service_status.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final GetAllInvoices _getAllInvoices;
  final UpdateInvoiceServiceStatus _updateInvoiceServiceStatus;
  final DeleteInvoice _deleteInvoice;

  InvoiceBloc({
    required GetAllInvoices getAllInvoices,
    required UpdateInvoiceServiceStatus updateInvoiceServiceStatus,
    required DeleteInvoice deleteInvoice,
  }) : _getAllInvoices = getAllInvoices,
       _updateInvoiceServiceStatus = updateInvoiceServiceStatus,
       _deleteInvoice = deleteInvoice,
       super(const InvoiceState()) {
    on<InvoiceListRequested>(_onInvoiceListRequested);
    on<InvoiceServiceCompleted>(_onInvoiceServiceCompleted);
    on<InvoiceDeleted>(_onInvoiceDeleted);
    add(const InvoiceListRequested());
  }

  Future<void> _onInvoiceListRequested(
    InvoiceListRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getAllInvoices(null);

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (invoices) =>
          emit(state.copyWith(isLoading: false, invoices: invoices)),
    );
  }

  Future<void> _onInvoiceServiceCompleted(
    InvoiceServiceCompleted event,
    Emitter<InvoiceState> emit,
  ) async {
    final result = await _updateInvoiceServiceStatus(
      UpdateInvoiceServiceStatusParams(
        invoiceId: event.invoiceId,
        status: ServiceStatus.completed,
      ),
    );

    final failure = result.fold((failure) => failure, (_) => null);
    if (failure != null) {
      emit(state.copyWith(errorMessage: failure.message));
      return;
    }

    add(const InvoiceListRequested());
  }

  Future<void> _onInvoiceDeleted(
    InvoiceDeleted event,
    Emitter<InvoiceState> emit,
  ) async {
    final result = await _deleteInvoice(event.invoiceId);

    final failure = result.fold((failure) => failure, (_) => null);
    if (failure != null) {
      emit(state.copyWith(errorMessage: failure.message));
      return;
    }

    add(const InvoiceListRequested());
  }
}
