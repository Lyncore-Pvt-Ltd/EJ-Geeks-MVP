import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/app_storage_paths.dart';
import '../../domain/entities/invoice_details.dart';
import '../../domain/entities/invoice_details_bundle.dart';
import '../../domain/entities/invoice_line_item.dart';
import '../../domain/entities/invoice_summary.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/entities/service_status.dart';

class InvoiceLocalDataSource {
  final AppDatabase _appDatabase;

  InvoiceLocalDataSource({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<void> upsertInvoiceDraft(String invoiceId) async {
    try {
      final db = await _appDatabase.database;
      final existing = await db.query(
        'invoices',
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
      if (existing.isNotEmpty) return;

      final now = DateTime.now().toIso8601String();
      await db.insert('invoices', {
        'id': invoiceId,
        'service_status': ServiceStatus.ongoingService.toDb(),
        'payment_status': PaymentStatus.pending.toDb(),
        'created_at': now,
        'updated_at': now,
      });
    } catch (e) {
      throw CacheException(message: 'Failed to save invoice draft: $e');
    }
  }

  Future<List<InvoiceSummary>> getAllInvoices() async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.rawQuery('''
        SELECT invoices.id AS id,
               invoices.service_status AS service_status,
               invoices.payment_status AS payment_status,
               invoices.created_at AS created_at,
               invoices.updated_at AS updated_at,
               inspections.owner_name AS owner_name,
               inspections.make AS make,
               inspections.model AS model,
               inspections.rego AS rego
        FROM invoices
        LEFT JOIN inspections ON inspections.invoice_id = invoices.id
        ORDER BY invoices.updated_at DESC
      ''');

      return rows
          .map(
            (row) => InvoiceSummary(
              id: row['id'] as String,
              serviceStatus: ServiceStatus.fromDb(
                row['service_status'] as String,
              ),
              paymentStatus: PaymentStatus.fromDb(
                row['payment_status'] as String,
              ),
              ownerName: row['owner_name'] as String? ?? '',
              make: row['make'] as String? ?? '',
              model: row['model'] as String? ?? '',
              rego: row['rego'] as String? ?? '',
              createdAt: DateTime.parse(row['created_at'] as String),
              updatedAt: DateTime.parse(row['updated_at'] as String),
            ),
          )
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to load invoices: $e');
    }
  }

  Future<void> updateServiceStatus(
    String invoiceId,
    ServiceStatus status,
  ) async {
    try {
      final db = await _appDatabase.database;
      await db.update(
        'invoices',
        {
          'service_status': status.toDb(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
    } catch (e) {
      throw CacheException(message: 'Failed to update invoice status: $e');
    }
  }

  Future<void> saveInvoiceDetails(
    InvoiceDetails details,
    List<InvoiceLineItem> items,
  ) async {
    try {
      final db = await _appDatabase.database;
      await db.transaction((txn) async {
        await txn.update(
          'invoices',
          {
            'issue_date': details.issueDate?.toIso8601String(),
            'due_date': details.dueDate?.toIso8601String(),
            'payment_terms': details.paymentTerms,
            'notes': details.notes,
            'vat_percent': details.vatPercent,
            'discount_percent': details.discountPercent,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [details.invoiceId],
        );

        await txn.delete(
          'invoice_items',
          where: 'invoice_id = ?',
          whereArgs: [details.invoiceId],
        );
        for (final item in items) {
          await txn.insert('invoice_items', {
            'id': item.id,
            'invoice_id': details.invoiceId,
            'name': item.name,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
          });
        }
      });
    } catch (e) {
      throw CacheException(message: 'Failed to save invoice details: $e');
    }
  }

  Future<InvoiceDetailsBundle> getInvoiceDetailsByInvoiceId(
    String invoiceId,
  ) async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        'invoices',
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
      final itemRows = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );
      final row = rows.isEmpty ? null : rows.first;

      final issueDateRaw = row?['issue_date'] as String?;
      final dueDateRaw = row?['due_date'] as String?;

      final details = InvoiceDetails(
        invoiceId: invoiceId,
        issueDate: issueDateRaw != null ? DateTime.parse(issueDateRaw) : null,
        dueDate: dueDateRaw != null ? DateTime.parse(dueDateRaw) : null,
        paymentTerms: row?['payment_terms'] as String? ?? '',
        notes: row?['notes'] as String? ?? '',
        vatPercent: (row?['vat_percent'] as num?)?.toDouble() ?? 0,
        discountPercent: (row?['discount_percent'] as num?)?.toDouble() ?? 0,
      );

      final items = itemRows
          .map(
            (r) => InvoiceLineItem(
              id: r['id'] as String,
              name: r['name'] as String,
              quantity: (r['quantity'] as num).toDouble(),
              unitPrice: (r['unit_price'] as num).toDouble(),
            ),
          )
          .toList();

      return InvoiceDetailsBundle(details: details, items: items);
    } catch (e) {
      throw CacheException(message: 'Failed to load invoice details: $e');
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      final db = await _appDatabase.database;
      final inspectionRows = await db.query(
        'inspections',
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );

      await db.transaction((txn) async {
        for (final row in inspectionRows) {
          final inspectionId = row['id'] as String;
          await txn.delete(
            'inspection_items',
            where: 'inspection_id = ?',
            whereArgs: [inspectionId],
          );
          await txn.delete(
            'inspection_section_comments',
            where: 'inspection_id = ?',
            whereArgs: [inspectionId],
          );
          await txn.delete(
            'inspection_images',
            where: 'inspection_id = ?',
            whereArgs: [inspectionId],
          );
        }

        await txn.delete(
          'inspections',
          where: 'invoice_id = ?',
          whereArgs: [invoiceId],
        );
        await txn.delete(
          'invoice_items',
          where: 'invoice_id = ?',
          whereArgs: [invoiceId],
        );
        await txn.delete('invoices', where: 'id = ?', whereArgs: [invoiceId]);
      });

      final imagesDir = await AppStoragePaths.imagesDir();
      final invoiceImagesDir = Directory(p.join(imagesDir.path, invoiceId));
      if (await invoiceImagesDir.exists()) {
        await invoiceImagesDir.delete(recursive: true);
      }

      final pdfDir = await AppStoragePaths.pdfDir();
      final invoicePdfDir = Directory(p.join(pdfDir.path, invoiceId));
      if (await invoicePdfDir.exists()) {
        await invoicePdfDir.delete(recursive: true);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to delete invoice: $e');
    }
  }
}
