import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice_details.dart';
import '../entities/invoice_line_item.dart';
import '../repositories/invoice_repository.dart';

class SaveInvoiceDetailsParams extends Equatable {
  final InvoiceDetails details;
  final List<InvoiceLineItem> items;

  const SaveInvoiceDetailsParams({required this.details, required this.items});

  @override
  List<Object?> get props => [details, items];
}

class SaveInvoiceDetails implements UseCase<void, SaveInvoiceDetailsParams> {
  final InvoiceRepository _repository;

  SaveInvoiceDetails(this._repository);

  @override
  Future<Either<Failure, void>> call(SaveInvoiceDetailsParams params) {
    return _repository.saveInvoiceDetails(params.details, params.items);
  }
}
