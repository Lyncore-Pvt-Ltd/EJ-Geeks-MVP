import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/app_storage_paths.dart';
import '../../domain/entities/invoice_defaults.dart';
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
               invoices.gst_percent AS gst_percent,
               invoices.discount_percent AS discount_percent,
               inspections.owner_name AS owner_name,
               inspections.make AS make,
               inspections.model AS model,
               inspections.rego AS rego,
               inspections.year AS year,
               inspections.phone_number AS phone_number,
               (SELECT SUM(quantity * unit_price) FROM invoice_items
                WHERE invoice_items.invoice_id = invoices.id) AS net_total
        FROM invoices
        LEFT JOIN inspections ON inspections.invoice_id = invoices.id
        ORDER BY invoices.updated_at DESC
      ''');

      return rows
          .map((row) {
            final netTotal = (row['net_total'] as num?)?.toDouble();
            final gstPercent = (row['gst_percent'] as num?)?.toDouble() ?? 0;
            final discountPercent =
                (row['discount_percent'] as num?)?.toDouble() ?? 0;
            final totalAmount = netTotal == null
                ? null
                : netTotal +
                      (netTotal * gstPercent / 100) -
                      (netTotal * discountPercent / 100);

            return InvoiceSummary(
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
              year: row['year'] as String? ?? '',
              phoneNumber: row['phone_number'] as String? ?? '',
              createdAt: DateTime.parse(row['created_at'] as String),
              updatedAt: DateTime.parse(row['updated_at'] as String),
              totalAmount: totalAmount,
            );
          })
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

  Future<void> updatePaymentStatus(
    String invoiceId,
    PaymentStatus status,
  ) async {
    try {
      final db = await _appDatabase.database;
      await db.update(
        'invoices',
        {
          'payment_status': status.toDb(),
          'paid_at': status == PaymentStatus.paid
              ? DateTime.now().toIso8601String()
              : null,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
    } catch (e) {
      throw CacheException(message: 'Failed to update payment status: $e');
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
            'gst_percent': details.gstPercent,
            'discount_percent': details.discountPercent,
            'app_owner_address': details.appOwnerAddress,
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

  Future<void> updatePdfContentSignature(
    String invoiceId,
    String? signature,
  ) async {
    try {
      final db = await _appDatabase.database;
      await db.update(
        'invoices',
        {'pdf_content_signature': signature},
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to update PDF content signature: $e',
      );
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
        gstPercent: (row?['gst_percent'] as num?)?.toDouble() ?? 0,
        discountPercent: (row?['discount_percent'] as num?)?.toDouble() ?? 0,
        appOwnerAddress: row?['app_owner_address'] as String? ?? '',
        paymentStatus: PaymentStatus.fromDb(
          row?['payment_status'] as String? ?? PaymentStatus.pending.toDb(),
        ),
        paidAt: (row?['paid_at'] as String?) != null
            ? DateTime.parse(row!['paid_at'] as String)
            : null,
        pdfContentSignature: row?['pdf_content_signature'] as String?,
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

  Future<InvoiceDefaults> getMostRecentInvoiceDefaults() async {
    try {
      final db = await _appDatabase.database;
      final addressRows = await db.query(
        'invoices',
        columns: ['app_owner_address'],
        where: "app_owner_address IS NOT NULL AND app_owner_address != ''",
        orderBy: 'updated_at DESC',
        limit: 1,
      );
      final termsRows = await db.query(
        'invoices',
        columns: ['payment_terms'],
        where: "payment_terms IS NOT NULL AND payment_terms != ''",
        orderBy: 'updated_at DESC',
        limit: 1,
      );
      return InvoiceDefaults(
        appOwnerAddress: addressRows.isEmpty
            ? null
            : addressRows.first['app_owner_address'] as String?,
        paymentTerms: termsRows.isEmpty
            ? null
            : termsRows.first['payment_terms'] as String?,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to load invoice defaults: $e');
    }
  }

  Future<void> deleteInvoice(
    String invoiceId, {
    bool deleteFiles = false,
  }) async {
    try {
      final db = await _appDatabase.database;
      final invoiceRows = await db.query(
        'invoices',
        columns: ['created_at'],
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
      final createdAt = invoiceRows.isEmpty
          ? DateTime.now()
          : DateTime.parse(invoiceRows.first['created_at'] as String);

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

      if (deleteFiles) {
        final invoiceFolder = await AppStoragePaths.invoiceFolder(
          invoiceId,
          createdAt,
        );
        if (await invoiceFolder.exists()) {
          await invoiceFolder.delete(recursive: true);
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to delete invoice: $e');
    }
  }
}
