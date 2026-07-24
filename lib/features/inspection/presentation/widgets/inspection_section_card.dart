import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inspection_section.dart';
import '../bloc/inspection_bloc.dart';
import '../bloc/inspection_event.dart';
import 'inspection_text_field.dart';
import 'rating_selector.dart';

class InspectionSectionCard extends StatelessWidget {
  const InspectionSectionCard({super.key, required this.section});

  final InspectionSection section;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = context.read<InspectionBloc>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppPallete.cascadingWhite
                  : AppPallete.tricornBlack,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppPallete.cascadingWhite
                          : AppPallete.tricornBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RatingSelector(
                    selected: item.rating,
                    onChanged: (rating) => bloc.add(
                      RatingChanged(
                        sectionName: section.name,
                        itemLabel: item.label,
                        rating: rating,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          InspectionTextField(
            key: ValueKey('comment_${section.name}'),
            initialValue: section.comment,
            label: 'Comments',
            growable: true,
            onChanged: (value) => bloc.add(
              SectionCommentChanged(sectionName: section.name, comment: value),
            ),
          ),
        ],
      ),
    );
  }
}
