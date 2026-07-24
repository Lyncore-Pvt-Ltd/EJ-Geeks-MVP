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

  static Future<Directory> imagesDir() async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, 'images'));
    return dir.create(recursive: true);
  }

  static Future<Directory> pdfDir() async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, 'pdf'));
    return dir.create(recursive: true);
  }

  /// Builds a new, unique, date/time-based path for an image belonging to
  /// [invoiceId], creating the per-invoice folder if needed.
  static Future<String> newImagePath(String invoiceId) async {
    final images = await imagesDir();
    final invoiceDir = Directory(p.join(images.path, invoiceId));
    await invoiceDir.create(recursive: true);

    final now = DateTime.now();
    final timestamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final shortId = now.microsecondsSinceEpoch.toRadixString(36);

    return p.join(invoiceDir.path, '${timestamp}_$shortId.jpg');
  }

  /// Builds the path for a generated PDF belonging to [invoiceId].
  static Future<String> newPdfPath(String invoiceId, String fileName) async {
    final pdf = await pdfDir();
    final invoiceDir = Directory(p.join(pdf.path, invoiceId));
    await invoiceDir.create(recursive: true);
    return p.join(invoiceDir.path, fileName);
  }
}
