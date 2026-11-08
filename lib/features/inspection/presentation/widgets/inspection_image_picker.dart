import 'dart:io';

import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_spinner.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
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
    final tokens = AutoFlowTokens.of(context);

    Widget option(
      BuildContext sheetContext,
      IconData icon,
      String label,
      ImageSource value,
    ) {
      return ListTile(
        minTileHeight: AfSpace.controlHeight,
        shape: const RoundedRectangleBorder(borderRadius: AfRadius.controlAll),
        onTap: () => Navigator.pop(sheetContext, value),
        leading: Icon(icon, color: tokens.ink),
        title: Text(
          label,
          style: AutoFlowTokens.body.copyWith(
            color: tokens.ink,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AutoFlowTokens.scrim,
      sheetAnimationStyle: afSheetAnimation(context),
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AfSpace.gutter,
            0,
            AfSpace.gutter,
            AfSpace.l24,
          ),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: AfRadius.cardAll,
            border: Border.all(color: tokens.line),
            boxShadow: AutoFlowTokens.cardShadow,
          ),
          // Ink from the option tiles paints on this, above the card fill.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: AfSpace.s12,
                    bottom: AfSpace.s8,
                  ),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.line,
                    borderRadius: AfRadius.chipAll,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AfSpace.s8,
                    vertical: AfSpace.xs4,
                  ),
                  child: Column(
                    children: [
                      option(
                        sheetContext,
                        Icons.photo_camera_outlined,
                        'Take photo',
                        ImageSource.camera,
                      ),
                      Divider(
                        color: tokens.line,
                        height: 1,
                        indent: AfSpace.m16,
                        endIndent: AfSpace.m16,
                      ),
                      option(
                        sheetContext,
                        Icons.photo_library_outlined,
                        'Choose from phone',
                        ImageSource.gallery,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AfSpace.s8),
              ],
            ),
          ),
        ),
      ),
    );

    if (source != null && context.mounted) {
      bloc.add(ImagePicked(source, sectionName: sectionName));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

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
                  padding: const EdgeInsets.only(right: AfSpace.s8),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        foregroundDecoration: BoxDecoration(
                          borderRadius: AfRadius.cardAll,
                          border: Border.all(color: tokens.line),
                        ),
                        child: ClipRRect(
                          borderRadius: AfRadius.cardAll,
                          child: Image.file(
                            File(path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Semantics(
                          button: true,
                          label: 'Remove photo',
                          excludeSemantics: true,
                          child: AfPressable(
                            pressedScale: 0.9,
                            focusRadius: AfRadius.chipAll,
                            onTap: () => context.read<InspectionBloc>().add(
                              ImageRemoved(path, sectionName: sectionName),
                            ),
                            child: SizedBox(
                              width: AfSpace.minTap,
                              height: AfSpace.minTap,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AutoFlowTokens.navyInk.withValues(
                                      alpha: 0.72,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AutoFlowTokens.light.card,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Semantics(
                button: true,
                enabled: !isPickingImage,
                label: isPickingImage ? 'Adding photo' : 'Add photo',
                excludeSemantics: true,
                child: Tooltip(
                  message: 'Add photo',
                  child: AfPressable(
                    onTap: isPickingImage
                        ? null
                        : () => _showSourceSheet(context),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: tokens.soft,
                        borderRadius: AfRadius.cardAll,
                        border: Border.all(color: tokens.line),
                      ),
                      child: Center(
                        child: isPickingImage
                            ? AfSpinner(
                                size: 20,
                                color: tokens.ink,
                                track: tokens.line,
                              )
                            : Icon(
                                Icons.add_a_photo_outlined,
                                color: tokens.mute2,
                              ),
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
