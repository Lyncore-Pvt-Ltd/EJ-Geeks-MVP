import 'dart:io';
import 'dart:typed_data';

import '../error/exceptions.dart';

/// Writes generated PDF bytes to disk, translating any I/O failure into the
/// app-wide [StorageException] convention.
Future<void> writePdfBytes(String path, Uint8List bytes) async {
  try {
    await File(path).writeAsBytes(bytes);
  } catch (e) {
    throw StorageException(message: 'Failed to save PDF: $e');
  }
}
