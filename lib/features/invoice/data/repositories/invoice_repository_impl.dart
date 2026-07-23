import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/invoice_summary.dart';
import '../../domain/entities/service_status.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_local_data_source.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceLocalDataSource _localDataSource;

  InvoiceRepositoryImpl({InvoiceLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? InvoiceLocalDataSource();

  @override
  Future<Either<Failure, void>> upsertInvoiceDraft(String invoiceId) async {
    try {
      await _localDataSource.upsertInvoiceDraft(invoiceId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceSummary>>> getAllInvoices() async {
    try {
      final invoices = await _localDataSource.getAllInvoices();
      return Right(invoices);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateServiceStatus(
    String invoiceId,
    ServiceStatus status,
  ) async {
    try {
      await _localDataSource.updateServiceStatus(invoiceId, status);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvoice(String invoiceId) async {
    try {
      await _localDataSource.deleteInvoice(invoiceId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
