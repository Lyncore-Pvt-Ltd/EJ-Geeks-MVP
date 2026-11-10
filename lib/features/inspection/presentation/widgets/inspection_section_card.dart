import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inspection_section.dart';
import '../bloc/inspection_bloc.dart';
import '../bloc/inspection_event.dart';
import 'inspection_image_picker.dart';
import 'inspection_text_field.dart';
import 'rating_selector.dart';

/// One checklist section, drawn as a DESIGN.md card: title + mono rated
/// counter, item rows split by 1px line rules (none after the last), then
/// photos and the section comment.
class InspectionSectionCard extends StatelessWidget {
  const InspectionSectionCard({super.key, required this.section});

  final InspectionSection section;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final bloc = context.read<InspectionBloc>();
    final items = section.items;
    final rated = items.where((item) => item.rating != null).length;

    return Container(
      margin: const EdgeInsets.only(bottom: AfSpace.m16),
      padding: const EdgeInsets.all(AfSpace.m16),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AfRadius.cardAll,
        border: Border.all(color: tokens.line),
        boxShadow: AutoFlowTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    section.name,
                    style: AutoFlowTokens.title.copyWith(color: tokens.ink),
                  ),
                ),
              ),
              const SizedBox(width: AfSpace.s8),
              Semantics(
                label: '$rated of ${items.length} items rated',
                excludeSemantics: true,
                child: Text(
                  '$rated / ${items.length}',
                  style: AutoFlowTokens.mono(
                    color: rated == items.length && items.isNotEmpty
                        ? AutoFlowTokens.successFg
                        : tokens.mute,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AfSpace.s8),
          for (var i = 0; i < items.length; i++)
            Container(
              padding: const EdgeInsets.only(top: AfSpace.s12),
              decoration: i == items.length - 1
                  ? null
                  : BoxDecoration(
                      border: Border(bottom: BorderSide(color: tokens.line)),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i].label,
                    style: AutoFlowTokens.body.copyWith(color: tokens.ink),
                  ),
                  const SizedBox(height: AfSpace.xs4),
                  RatingSelector(
                    selected: items[i].rating,
                    onChanged: (rating) => bloc.add(
                      RatingChanged(
                        sectionName: section.name,
                        itemLabel: items[i].label,
                        rating: rating,
                      ),
                    ),
                  ),
                  const SizedBox(height: AfSpace.xs4),
                ],
              ),
            ),
          const SizedBox(height: AfSpace.m16),
          if (section.name != 'Road Test') ...[
            InspectionImagePicker(sectionName: section.name),
            const SizedBox(height: AfSpace.m16),
          ],
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
