import 'package:equatable/equatable.dart';

import 'inspection_checklist_item.dart';

class InspectionSection extends Equatable {
  final String name;
  final List<InspectionChecklistItem> items;
  final String comment;

  const InspectionSection({
    required this.name,
    required this.items,
    this.comment = '',
  });

  InspectionSection copyWith({
    List<InspectionChecklistItem>? items,
    String? comment,
  }) {
    return InspectionSection(
      name: name,
      items: items ?? this.items,
      comment: comment ?? this.comment,
    );
  }

  @override
  List<Object?> get props => [name, items, comment];
}
