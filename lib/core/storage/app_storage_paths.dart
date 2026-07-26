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
    final dir = Directory(
      p.join(base.path, _dateKey(createdAt), invoiceId),
    );
    return dir.create(recursive: true);
  }

  static Future<Directory> imagesDir(String invoiceId, DateTime createdAt) async {
    final folder = await invoiceFolder(invoiceId, createdAt);
    final dir = Directory(p.join(folder.path, 'images'));
    return dir.create(recursive: true);
  }

  /// Builds a new, unique, date/time-based path for an image belonging to
  /// [invoiceId], creating the per-invoice images folder if needed.
  static Future<String> newImagePath(
    String invoiceId,
    DateTime createdAt,
  ) async {
    final images = await imagesDir(invoiceId, createdAt);

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
