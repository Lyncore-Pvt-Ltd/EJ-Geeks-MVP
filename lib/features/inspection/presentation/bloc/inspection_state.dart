import 'package:equatable/equatable.dart';

import '../../domain/entities/inspection_section.dart';

class InspectionState extends Equatable {
  final List<InspectionSection> sections;
  final List<String> imagePaths;
  final bool isPickingImage;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const InspectionState({
    required this.sections,
    this.imagePaths = const [],
    this.isPickingImage = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  InspectionState copyWith({
    List<InspectionSection>? sections,
    List<String>? imagePaths,
    bool? isPickingImage,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
  }) {
    return InspectionState(
      sections: sections ?? this.sections,
      imagePaths: imagePaths ?? this.imagePaths,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? false,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    sections,
    imagePaths,
    isPickingImage,
    isSaving,
    saveSuccess,
    errorMessage,
  ];
}
