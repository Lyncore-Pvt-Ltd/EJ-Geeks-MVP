import 'dart:io';

import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/inspection_bloc.dart';
import '../bloc/inspection_event.dart';
import '../bloc/inspection_state.dart';

class InspectionImagePicker extends StatelessWidget {
  const InspectionImagePicker({super.key});

  Future<void> _showSourceSheet(BuildContext context) async {
    final bloc = context.read<InspectionBloc>();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from phone'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null && context.mounted) {
      bloc.add(ImagePicked(source));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<InspectionBloc, InspectionState>(
      buildWhen: (previous, current) =>
          previous.imagePaths != current.imagePaths ||
          previous.isPickingImage != current.isPickingImage,
      builder: (context, state) {
        return SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final path in state.imagePaths)
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
                            ImageRemoved(path),
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
                  color: isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: state.isPickingImage
                        ? null
                        : () => _showSourceSheet(context),
                    child: Center(
                      child: state.isPickingImage
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
