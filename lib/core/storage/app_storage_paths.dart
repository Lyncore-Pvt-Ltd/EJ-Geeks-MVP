import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppStoragePaths {
  AppStoragePaths._();

  static const String appFolderName = 'EJ Geek Invoice';

  static Future<Directory> _baseDir() async {
    final root = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final base = Directory(p.join(root!.path, appFolderName));
    return base.create(recursive: true);
  }

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}'
      '${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';

  /// The per-invoice folder: `<base>/<yyyyMMdd>/<invoiceId>/`, grouping the
  /// invoice's images and generated PDFs together under the day it was
  /// created.
  static Future<Directory> invoiceFolder(
    String invoiceId,
    DateTime createdAt,
  ) async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, _dateKey(createdAt), invoiceId));
    return dir.create(recursive: true);
  }

  /// Collapses a section name like `Tyres, Wheels & Brakes` into a
  /// filesystem-safe subfolder segment like `tyres_wheels_brakes`.
  static String _sanitizeSection(String section) => section
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  static Future<Directory> imagesDir(
    String invoiceId,
    DateTime createdAt, {
    String? section,
  }) async {
    final folder = await invoiceFolder(invoiceId, createdAt);
    final dir = Directory(
      section == null
          ? p.join(folder.path, 'images')
          : p.join(folder.path, 'images', _sanitizeSection(section)),
    );
    return dir.create(recursive: true);
  }

  /// Builds a new, unique, date/time-based path for an image belonging to
  /// [invoiceId], creating the per-invoice images folder if needed. Pass
  /// [section] to file the image under that section's own subfolder instead
  /// of the shared images folder.
  static Future<String> newImagePath(
    String invoiceId,
    DateTime createdAt, {
    String? section,
  }) async {
    final images = await imagesDir(invoiceId, createdAt, section: section);

    final now = DateTime.now();
    final timestamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final shortId = now.microsecondsSinceEpoch.toRadixString(36);

    return p.join(images.path, '${timestamp}_$shortId.jpg');
  }

  /// Path for the invoice's generated invoice PDF.
  static Future<String> invoicePdfPath(
    String invoiceId,
    DateTime createdAt,
  ) async {
    final folder = await invoiceFolder(invoiceId, createdAt);
    return p.join(folder.path, 'invoice.pdf');
  }

  /// Path for the invoice's generated inspection report PDF.
  static Future<String> inspectionPdfPath(
    String invoiceId,
    DateTime createdAt,
  ) async {
    final folder = await invoiceFolder(invoiceId, createdAt);
    return p.join(folder.path, 'inspection.pdf');
  }
}
