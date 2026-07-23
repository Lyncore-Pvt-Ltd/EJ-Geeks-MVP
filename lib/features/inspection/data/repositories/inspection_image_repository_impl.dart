import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/inspection_image_repository.dart';
import '../datasources/inspection_image_data_source.dart';

class InspectionImageRepositoryImpl implements InspectionImageRepository {
  final InspectionImageDataSource _dataSource;

  InspectionImageRepositoryImpl({InspectionImageDataSource? dataSource})
    : _dataSource = dataSource ?? InspectionImageDataSource();

  @override
  Future<Either<Failure, String?>> pickAndStoreImage({
    required ImageSource source,
    required String invoiceId,
  }) async {
    try {
      final path = await _dataSource.pickAndStoreImage(
        source: source,
        invoiceId: invoiceId,
      );
      return Right(path);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    }
  }
}
