import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/inspection_checklist_item.dart';
import '../../domain/entities/inspection_record.dart';
import '../../domain/entities/inspection_section.dart';
import '../../domain/entities/rating_option.dart';
import '../../domain/entities/vehicle_details.dart';

class InspectionLocalDataSource {
  final AppDatabase _appDatabase;

  InspectionLocalDataSource({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<void> saveInspection(InspectionRecord record) async {
    try {
      final db = await _appDatabase.database;
      await db.transaction((txn) async {
        final batch = txn.batch();

        batch.insert('inspections', {
          'id': record.id,
          'invoice_id': record.invoiceId,
          'make': record.vehicleDetails.make,
          'model': record.vehicleDetails.model,
          'rego': record.vehicleDetails.rego,
          'year': record.vehicleDetails.year,
          'odometer': record.vehicleDetails.odometer,
          'vin': record.vehicleDetails.vin,
          'engine_no': record.vehicleDetails.engineNo,
          'owner_name': record.vehicleDetails.ownerName,
          'address': record.vehicleDetails.address,
          'phone_number': record.vehicleDetails.phoneNumber,
          'created_at': record.createdAt.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        batch.delete(
          'inspection_items',
          where: 'inspection_id = ?',
          whereArgs: [record.id],
        );
        batch.delete(
          'inspection_section_comments',
          where: 'inspection_id = ?',
          whereArgs: [record.id],
        );
        batch.delete(
          'inspection_images',
          where: 'inspection_id = ?',
          whereArgs: [record.id],
        );

        for (final section in record.sections) {
          for (final item in section.items) {
            batch.insert('inspection_items', {
              'id': '${record.id}_${section.name}_${item.label}',
              'inspection_id': record.id,
              'section': section.name,
              'item_label': item.label,
              'rating': item.rating?.label,
            });
          }

          batch.insert('inspection_section_comments', {
            'id': '${record.id}_${section.name}_comment',
            'inspection_id': record.id,
            'section': section.name,
            'comment': section.comment,
          });

          for (var i = 0; i < section.imagePaths.length; i++) {
            batch.insert('inspection_images', {
              'id': '${record.id}_${section.name}_image_$i',
              'inspection_id': record.id,
              'section': section.name,
              'file_path': section.imagePaths[i],
              'created_at': record.createdAt.toIso8601String(),
            });
          }
        }

        for (var i = 0; i < record.imagePaths.length; i++) {
          batch.insert('inspection_images', {
            'id': '${record.id}_image_$i',
            'inspection_id': record.id,
            'file_path': record.imagePaths[i],
            'created_at': record.createdAt.toIso8601String(),
          });
        }

        await batch.commit(noResult: true);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to save inspection: $e');
    }
  }

  Future<InspectionRecord?> getInspection(String id) async {
    try {
      final db = await _appDatabase.database;

      final inspectionRows = await db.query(
        'inspections',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (inspectionRows.isEmpty) return null;
      final row = inspectionRows.first;

      final itemRows = await db.query(
        'inspection_items',
        where: 'inspection_id = ?',
        whereArgs: [id],
      );
      final commentRows = await db.query(
        'inspection_section_comments',
        where: 'inspection_id = ?',
        whereArgs: [id],
      );
      final imageRows = await db.query(
        'inspection_images',
        where: 'inspection_id = ?',
        whereArgs: [id],
      );

      final sectionNames = <String>{
        ...itemRows.map((r) => r['section'] as String),
        ...commentRows.map((r) => r['section'] as String),
      };

      final sections = sectionNames.map((sectionName) {
        final items = itemRows
            .where((r) => r['section'] == sectionName)
            .map(
              (r) => InspectionChecklistItem(
                label: r['item_label'] as String,
                rating: RatingOption.fromLabel(r['rating'] as String?),
              ),
            )
            .toList();
        final comment =
            commentRows.firstWhere(
                  (r) => r['section'] == sectionName,
                  orElse: () => const {},
                )['comment']
                as String?;
        final sectionImagePaths = imageRows
            .where((r) => r['section'] == sectionName)
            .map((r) => r['file_path'] as String)
            .toList();
        return InspectionSection(
          name: sectionName,
          items: items,
          comment: comment ?? '',
          imagePaths: sectionImagePaths,
        );
      }).toList();

      final globalImagePaths = imageRows
          .where((r) => r['section'] == null)
          .map((r) => r['file_path'] as String)
          .toList();

      return InspectionRecord(
        id: row['id'] as String,
        invoiceId: row['invoice_id'] as String,
        vehicleDetails: VehicleDetails(
          make: row['make'] as String? ?? '',
          model: row['model'] as String? ?? '',
          rego: row['rego'] as String? ?? '',
          year: row['year'] as String? ?? '',
          odometer: row['odometer'] as String? ?? '',
          vin: row['vin'] as String? ?? '',
          engineNo: row['engine_no'] as String? ?? '',
          ownerName: row['owner_name'] as String? ?? '',
          address: row['address'] as String? ?? '',
          phoneNumber: row['phone_number'] as String? ?? '',
        ),
        sections: sections,
        imagePaths: globalImagePaths,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to load inspection: $e');
    }
  }

  Future<InspectionRecord?> getInspectionByInvoiceId(String invoiceId) async {
    try {
      final db = await _appDatabase.database;
      final inspectionRows = await db.query(
        'inspections',
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      if (inspectionRows.isEmpty) return null;
      return getInspection(inspectionRows.first['id'] as String);
    } catch (e) {
      throw CacheException(message: 'Failed to load inspection: $e');
    }
  }
}
