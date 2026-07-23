import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/app_storage_paths.dart';

class InspectionImageDataSource {
  final ImagePicker _imagePicker;

  InspectionImageDataSource({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  /// Picks an image from [source], downscales it, copies it into
  /// [invoiceId]'s image folder, and returns the new file's path.
  /// Returns null if the user cancelled the picker.
  Future<String?> pickAndStoreImage({
    required ImageSource source,
    required String invoiceId,
  }) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
      );
      if (picked == null) return null;

      final destinationPath = await AppStoragePaths.newImagePath(invoiceId);
      await File(picked.path).copy(destinationPath);
      return destinationPath;
    } catch (e) {
      throw StorageException(message: 'Failed to add photo: $e');
    }
  }
}
