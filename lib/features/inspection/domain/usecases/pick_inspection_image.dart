import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inspection_image_repository.dart';

class PickInspectionImageParams extends Equatable {
  final ImageSource source;
  final String invoiceId;

  const PickInspectionImageParams({
    required this.source,
    required this.invoiceId,
  });

  @override
  List<Object?> get props => [source, invoiceId];
}

class PickInspectionImage
    implements UseCase<String?, PickInspectionImageParams> {
  final InspectionImageRepository _repository;

  PickInspectionImage(this._repository);

  @override
  Future<Either<Failure, String?>> call(PickInspectionImageParams params) {
    return _repository.pickAndStoreImage(
      source: params.source,
      invoiceId: params.invoiceId,
    );
  }
}
