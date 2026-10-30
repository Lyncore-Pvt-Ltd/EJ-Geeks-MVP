import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../../../domain/entities/intro_slide.dart';
import '../common/af_motion.dart';
import 'highlights_illustration.dart';
import 'inspection_illustration.dart';
import 'photo_illustration.dart';

/// One intro slide: illustration panel above counter, headline and body.
/// Inactive slides dim to 40% and shrink to 0.94.
class IntroSlideView extends StatelessWidget {
  final IntroSlide slide;
  final int index;
  final int count;
  final bool active;
  final int tick;

  const IntroSlideView({
    super.key,
    required this.slide,
    required this.index,
    required this.count,
    required this.active,
    required this.tick,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: AnimatedOpacity(
                opacity: active ? 1 : 0.4,
                duration: afDuration(context, 400),
                curve: AutoFlowTokens.easeOut,
                child: AnimatedScale(
                  scale: active ? 1 : 0.94,
                  duration: afDuration(context, 500),
                  curve: AutoFlowTokens.easeOut,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: tokens.panel,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: tokens.line),
                    ),
                    // Illustrations are laid out at a fixed design width and
                    // scaled down on short screens rather than overflowing.
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _illustration(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AfReveal(
                  visible: active,
                  delayMs: 80,
                  dy: 12,
                  child: Text(
                    '0${index + 1} / 0$count',
                    style: AutoFlowTokens.mono(color: tokens.mute),
                  ),
                ),
                const SizedBox(height: 8),
                AfReveal(
                  visible: active,
                  delayMs: 140,
                  dy: 12,
                  child: Text(
                    slide.headline,
                    style: AutoFlowTokens.headline.copyWith(color: tokens.ink),
                  ),
                ),
                const SizedBox(height: 8),
                AfReveal(
                  visible: active,
                  delayMs: 200,
                  dy: 12,
                  child: Text(
                    slide.body,
                    style: AutoFlowTokens.body.copyWith(color: tokens.mute2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _illustration() {
    return switch (slide.illustration) {
      IntroIllustration.highlights => HighlightsIllustration(
        active: active,
        tick: tick,
      ),
      IntroIllustration.inspection => InspectionIllustration(
        active: active,
        tick: tick,
      ),
      IntroIllustration.photos => PhotoIllustration(active: active, tick: tick),
    };
  }
}
