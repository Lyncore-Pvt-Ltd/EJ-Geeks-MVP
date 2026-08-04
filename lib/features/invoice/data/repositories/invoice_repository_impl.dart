import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/invoice_details.dart';
import '../../domain/entities/invoice_details_bundle.dart';
import '../../domain/entities/invoice_line_item.dart';
import '../../domain/entities/invoice_summary.dart';
import '../../domain/entities/payment_status.dart';
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
  Future<Either<Failure, void>> updatePaymentStatus(
    String invoiceId,
    PaymentStatus status,
  ) async {
    try {
      await _localDataSource.updatePaymentStatus(invoiceId, status);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvoice(
    String invoiceId, {
    bool deleteFiles = false,
  }) async {
    try {
      await _localDataSource.deleteInvoice(invoiceId, deleteFiles: deleteFiles);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveInvoiceDetails(
    InvoiceDetails details,
    List<InvoiceLineItem> items,
  ) async {
    try {
      await _localDataSource.saveInvoiceDetails(details, items);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailsBundle>> getInvoiceDetailsByInvoiceId(
    String invoiceId,
  ) async {
    try {
      final bundle = await _localDataSource.getInvoiceDetailsByInvoiceId(
        invoiceId,
      );
      return Right(bundle);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePdfContentSignature(
    String invoiceId,
    String? signature,
  ) async {
    try {
      await _localDataSource.updatePdfContentSignature(invoiceId, signature);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
