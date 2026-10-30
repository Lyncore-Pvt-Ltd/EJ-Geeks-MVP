import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../../../data/constants/onboarding_content.dart';
import '../common/af_motion.dart';
import '../common/af_pop_in.dart';
import '../common/af_status_chip.dart';

/// Slide 2: an inspection card whose checklist rows get graded in sequence.
class InspectionIllustration extends StatelessWidget {
  final bool active;
  final int tick;

  const InspectionIllustration({
    super.key,
    required this.active,
    required this.tick,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    // 0..2 = row being graded, 3 = all graded, 4 = rest. Inactive shows done.
    final step = active ? tick % 5 : 4;

    return Container(
      width: 326,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.line),
        boxShadow: AutoFlowTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inspection',
                      style: AutoFlowTokens.caption.copyWith(
                        color: tokens.mute,
                      ),
                    ),
                    Text(
                      'Toyota Hilux',
                      maxLines: 1,
                      style: AutoFlowTokens.body.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        letterSpacing: -0.16,
                        color: tokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
              AfStatusChip(
                label: 'Global blueprint',
                background: const Color(0x29FCA311),
                foreground: tokens.ink,
                dotColor: AutoFlowTokens.accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [Colors.black, Colors.black, Colors.transparent],
              stops: [0, 0.8, 1],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  for (var i = 0; i < kIntroSections.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    _SectionChip(label: kIntroSections[i], selected: i == 0),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < kIntroChecks.length; i++)
            AfReveal(
              visible: active,
              delayMs: 150 + i * 70,
              child: _CheckRow(
                item: kIntroChecks[i].$1,
                rating: kIntroChecks[i].$2,
                rated: i < step,
                current: i == step,
              ),
            ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: step >= 3 ? 1 : 0,
            duration: afDuration(context, 300),
            curve: AutoFlowTokens.easeOut,
            child: AnimatedSlide(
              offset: Offset(0, step >= 3 ? 0 : 0.1),
              duration: afDuration(context, 400),
              curve: AutoFlowTokens.easeOut,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: tokens.soft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: tokens.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kIntroTechnicianNote,
                        style: AutoFlowTokens.caption.copyWith(
                          height: 1.35,
                          color: tokens.mute2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _SectionChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? tokens.ink : tokens.soft,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: AutoFlowTokens.caption.copyWith(
          fontWeight: FontWeight.w500,
          color: selected ? tokens.card : tokens.ink,
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String item;
  final String rating;
  final bool rated;
  final bool current;

  const _CheckRow({
    required this.item,
    required this.rating,
    required this.rated,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return AnimatedContainer(
      duration: afDuration(context, 300),
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: current ? const Color(0x24FCA311) : const Color(0x00FCA311),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item,
              style: AutoFlowTokens.caption.copyWith(
                fontWeight: current ? FontWeight.w500 : FontWeight.w400,
                color: tokens.ink,
              ),
            ),
          ),
          if (rated)
            AfPopIn(child: AfStatusChip.rating(rating))
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var k = 0; k < kIntroRatingKeys.length; k++) ...[
                  if (k > 0) const SizedBox(width: 4),
                  _RatingKey(
                    label: kIntroRatingKeys[k],
                    highlighted: current && kIntroRatingKeys[k] == rating[0],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _RatingKey extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _RatingKey({required this.label, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0x3DFCA311) : tokens.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tokens.line),
      ),
      child: Text(label, style: AutoFlowTokens.mono(color: tokens.mute)),
    );
  }
}
