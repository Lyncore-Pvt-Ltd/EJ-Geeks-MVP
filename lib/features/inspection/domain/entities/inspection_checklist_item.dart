import 'package:equatable/equatable.dart';

import 'rating_option.dart';

class InspectionChecklistItem extends Equatable {
  final String label;
  final RatingOption? rating;

  const InspectionChecklistItem({required this.label, this.rating});

  InspectionChecklistItem copyWith({RatingOption? rating}) {
    return InspectionChecklistItem(label: label, rating: rating ?? this.rating);
  }

  @override
  List<Object?> get props => [label, rating];
}
