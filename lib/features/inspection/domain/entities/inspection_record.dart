import 'package:equatable/equatable.dart';

import 'inspection_section.dart';
import 'vehicle_details.dart';

class InspectionRecord extends Equatable {
  final String id;
  final String invoiceId;
  final VehicleDetails vehicleDetails;
  final List<InspectionSection> sections;
  final List<String> imagePaths;
  final DateTime createdAt;

  const InspectionRecord({
    required this.id,
    required this.invoiceId,
    required this.vehicleDetails,
    required this.sections,
    required this.imagePaths,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    invoiceId,
    vehicleDetails,
    sections,
    imagePaths,
    createdAt,
  ];
}
