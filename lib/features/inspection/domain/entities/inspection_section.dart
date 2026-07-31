import 'package:equatable/equatable.dart';

import 'inspection_checklist_item.dart';

class InspectionSection extends Equatable {
  final String name;
  final List<InspectionChecklistItem> items;
  final String comment;
  final List<String> imagePaths;

  const InspectionSection({
    required this.name,
    required this.items,
    this.comment = '',
    this.imagePaths = const [],
  });

  InspectionSection copyWith({
    List<InspectionChecklistItem>? items,
    String? comment,
    List<String>? imagePaths,
  }) {
    return InspectionSection(
      name: name,
      items: items ?? this.items,
      comment: comment ?? this.comment,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  @override
  List<Object?> get props => [name, items, comment, imagePaths];
}
