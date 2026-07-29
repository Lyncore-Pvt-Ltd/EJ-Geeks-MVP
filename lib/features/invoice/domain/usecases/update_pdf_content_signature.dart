import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invoice_repository.dart';

class UpdatePdfContentSignatureParams extends Equatable {
  final String invoiceId;
  final String? signature;

  const UpdatePdfContentSignatureParams({
    required this.invoiceId,
    required this.signature,
  });

  @override
  List<Object?> get props => [invoiceId, signature];
}

class UpdatePdfContentSignature
    implements UseCase<void, UpdatePdfContentSignatureParams> {
  final InvoiceRepository _repository;

  UpdatePdfContentSignature(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdatePdfContentSignatureParams params) {
    return _repository.updatePdfContentSignature(
      params.invoiceId,
      params.signature,
    );
  }
}
