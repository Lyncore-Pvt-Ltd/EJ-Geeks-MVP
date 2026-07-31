import 'dart:io';

import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/inspection_bloc.dart';
import '../bloc/inspection_event.dart';
import '../bloc/inspection_state.dart';

class InspectionImagePicker extends StatelessWidget {
  /// Section to scope this picker's images to. Null (the default) targets
  /// the global, not section-scoped, image list.
  const InspectionImagePicker({super.key, this.sectionName});

  final String? sectionName;

  Future<void> _showSourceSheet(BuildContext context) async {
    final bloc = context.read<InspectionBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final groupColor = isDark ? AppPallete.warmOnyx : Colors.grey[200];
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final handleColor = isDark ? Colors.white24 : Colors.black26;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? AppPallete.invoiceCardGradientDark
                : AppPallete.invoiceCardGradientLight,
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: groupColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () =>
                        Navigator.pop(sheetContext, ImageSource.camera),
                    leading: Icon(
                      Icons.photo_camera_outlined,
                      color: textColor,
                    ),
                    title: Text(
                      'Take photo',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(
                    color: dividerColor,
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                    onTap: () =>
                        Navigator.pop(sheetContext, ImageSource.gallery),
                    leading: Icon(
                      Icons.photo_library_outlined,
                      color: textColor,
                    ),
                    title: Text(
                      'Choose from phone',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source != null && context.mounted) {
      bloc.add(ImagePicked(source, sectionName: sectionName));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocSelector<InspectionBloc, InspectionState, (List<String>, bool)>(
      selector: (state) => sectionName == null
          ? (
              state.imagePaths,
              state.isPickingImage && state.pickingSectionName == null,
            )
          : (
              state.sections
                  .firstWhere((s) => s.name == sectionName)
                  .imagePaths,
              state.isPickingImage && state.pickingSectionName == sectionName,
            ),
      builder: (context, data) {
        final (imagePaths, isPickingImage) = data;
        return SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final path in imagePaths)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => context.read<InspectionBloc>().add(
                            ImageRemoved(path, sectionName: sectionName),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: 80,
                height: 80,
                child: Material(
                  color: isDark
                      ? AppPallete.warmOnyx
                      : AppPallete.nebulousWhite,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isPickingImage
                        ? null
                        : () => _showSourceSheet(context),
                    child: Center(
                      child: isPickingImage
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.add_a_photo_outlined,
                              color: isDark
                                  ? AppPallete.cascadingWhite
                                  : AppPallete.tricornBlack,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
