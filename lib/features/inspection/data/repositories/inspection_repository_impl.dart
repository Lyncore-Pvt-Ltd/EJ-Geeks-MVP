import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/inspection_record.dart';
import '../../domain/repositories/inspection_repository.dart';
import '../datasources/inspection_local_data_source.dart';

class InspectionRepositoryImpl implements InspectionRepository {
  final InspectionLocalDataSource _localDataSource;

  InspectionRepositoryImpl({InspectionLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? InspectionLocalDataSource();

  @override
  Future<Either<Failure, void>> saveInspection(InspectionRecord record) async {
    try {
      await _localDataSource.saveInspection(record);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, InspectionRecord?>> getInspection(String id) async {
    try {
      final record = await _localDataSource.getInspection(id);
      return Right(record);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, InspectionRecord?>> getInspectionByInvoiceId(
    String invoiceId,
  ) async {
    try {
      final record = await _localDataSource.getInspectionByInvoiceId(
        invoiceId,
      );
      return Right(record);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
