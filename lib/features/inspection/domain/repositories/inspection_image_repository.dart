import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';

abstract class InspectionImageRepository {
  Future<Either<Failure, String?>> pickAndStoreImage({
    required ImageSource source,
    required String invoiceId,
  });
}
