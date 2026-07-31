import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/rating_option.dart';
import '../../domain/entities/vehicle_details.dart';

abstract class InspectionEvent extends Equatable {
  const InspectionEvent();

  @override
  List<Object?> get props => [];
}

class RatingChanged extends InspectionEvent {
  final String sectionName;
  final String itemLabel;
  final RatingOption rating;

  const RatingChanged({
    required this.sectionName,
    required this.itemLabel,
    required this.rating,
  });

  @override
  List<Object?> get props => [sectionName, itemLabel, rating];
}

class SectionCommentChanged extends InspectionEvent {
  final String sectionName;
  final String comment;

  const SectionCommentChanged({
    required this.sectionName,
    required this.comment,
  });

  @override
  List<Object?> get props => [sectionName, comment];
}

class ImagePicked extends InspectionEvent {
  final ImageSource source;

  /// Null targets the global (not section-scoped) image list.
  final String? sectionName;

  const ImagePicked(this.source, {this.sectionName});

  @override
  List<Object?> get props => [source, sectionName];
}

class ImageRemoved extends InspectionEvent {
  final String path;

  /// Null targets the global (not section-scoped) image list.
  final String? sectionName;

  const ImageRemoved(this.path, {this.sectionName});

  @override
  List<Object?> get props => [path, sectionName];
}

class InspectionLoadRequested extends InspectionEvent {
  const InspectionLoadRequested();
}

class InspectionSaved extends InspectionEvent {
  final VehicleDetails vehicleDetails;

  const InspectionSaved(this.vehicleDetails);

  @override
  List<Object?> get props => [vehicleDetails];
}
