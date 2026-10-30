import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../../../data/constants/onboarding_content.dart';
import '../common/af_motion.dart';

const _highlightIcons = [
  Icons.assignment_turned_in_outlined,
  Icons.photo_camera_outlined,
  Icons.apartment_outlined,
  Icons.receipt_long_outlined,
];

/// Slide 1: four feature tiles that take turns lifting with an accent border.
class HighlightsIllustration extends StatelessWidget {
  final bool active;
  final int tick;

  const HighlightsIllustration({
    super.key,
    required this.active,
    required this.tick,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 326,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          const Positioned(
            top: -24,
            child: AfGlow(width: 160, height: 96, blur: 40, opacity: 0.3),
          ),
          Column(
            children: [
              for (var row = 0; row < 2; row++) ...[
                if (row > 0) const SizedBox(height: 8),
                Row(
                  children: [
                    for (var col = 0; col < 2; col++) ...[
                      if (col > 0) const SizedBox(width: 8),
                      Expanded(child: _tile(context, row * 2 + col)),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, int i) {
    final (title, tag) = kIntroHighlights[i];
    return AfReveal(
      visible: active,
      delayMs: 150 + i * 60,
      child: _HighlightTile(
        icon: _highlightIcons[i],
        title: title,
        tag: tag,
        hot: active && tick % kIntroHighlights.length == i,
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String tag;
  final bool hot;

  const _HighlightTile({
    required this.icon,
    required this.title,
    required this.tag,
    required this.hot,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final duration = afDuration(context, 300);
    return AnimatedSlide(
      offset: Offset(0, hot ? -4 / 120 : 0),
      duration: afDuration(context, 400),
      curve: AutoFlowTokens.easeOut,
      child: AnimatedContainer(
        duration: duration,
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hot ? tokens.hot : tokens.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hot ? AutoFlowTokens.accent : tokens.line),
          boxShadow: [
            BoxShadow(
              color: hot ? const Color(0x8CFCA311) : const Color(0x00FCA311),
              offset: const Offset(0, 12),
              blurRadius: 24,
              spreadRadius: -12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: duration,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hot ? AutoFlowTokens.accent : tokens.soft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: hot ? AutoFlowTokens.onAccent : tokens.ink,
                  ),
                ),
                const Spacer(),
                AnimatedScale(
                  scale: hot ? 1 : 0,
                  duration: duration,
                  curve: AutoFlowTokens.easeSpring,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AutoFlowTokens.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AutoFlowTokens.caption.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
                letterSpacing: -0.13,
                color: tokens.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(tag, style: AutoFlowTokens.mono(color: tokens.mute)),
          ],
        ),
      ),
    );
  }
}
