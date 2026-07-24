import 'package:equatable/equatable.dart';

import '../../domain/entities/inspection_section.dart';
import '../../domain/entities/vehicle_details.dart';

class InspectionState extends Equatable {
  final List<InspectionSection> sections;
  final List<String> imagePaths;
  final VehicleDetails? vehicleDetails;
  final bool isPickingImage;
  final bool isSaving;
  final bool isLoading;
  final bool saveSuccess;
  final String? errorMessage;

  const InspectionState({
    required this.sections,
    this.imagePaths = const [],
    this.vehicleDetails,
    this.isPickingImage = false,
    this.isSaving = false,
    this.isLoading = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  InspectionState copyWith({
    List<InspectionSection>? sections,
    List<String>? imagePaths,
    VehicleDetails? vehicleDetails,
    bool? isPickingImage,
    bool? isSaving,
    bool? isLoading,
    bool? saveSuccess,
    String? errorMessage,
  }) {
    return InspectionState(
      sections: sections ?? this.sections,
      imagePaths: imagePaths ?? this.imagePaths,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      saveSuccess: saveSuccess ?? false,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    sections,
    imagePaths,
    vehicleDetails,
    isPickingImage,
    isSaving,
    isLoading,
    saveSuccess,
    errorMessage,
  ];
}
