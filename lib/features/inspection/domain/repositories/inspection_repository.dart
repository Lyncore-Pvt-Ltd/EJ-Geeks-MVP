import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/inspection_record.dart';

abstract class InspectionRepository {
  Future<Either<Failure, void>> saveInspection(InspectionRecord record);

  Future<Either<Failure, InspectionRecord?>> getInspection(String id);

  Future<Either<Failure, InspectionRecord?>> getInspectionByInvoiceId(
    String invoiceId,
  );
}
