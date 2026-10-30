import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../../../domain/entities/intro_slide.dart';
import '../common/af_layout.dart';
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

  static const _minPanelHeight = 160.0;
  static const _panelGap = 16.0;
  static const _minHeadlineSize = 20.0;

  String get _counterLabel => '0${index + 1} / 0$count';

  static TextStyle _headlineStyle(AutoFlowTokens tokens, double size) =>
      AutoFlowTokens.headline.copyWith(
        color: tokens.ink,
        fontSize: size,
        letterSpacing: -0.03 * size,
      );

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final layout = AfLayout.of(context);
    final bodyStyle = AutoFlowTokens.body.copyWith(color: tokens.mute2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Give the text exactly the room it needs and the panel the rest,
          // within [_minPanelHeight, panelMaxHeight]. The headline steps
          // down from the bucket size until the text fits beside the minimum
          // panel; if even the smallest headline doesn't fit (compact
          // screens), the text block scrolls instead of overflowing.
          final textWidth = constraints.maxWidth - 8;
          final textBudget =
              constraints.maxHeight - _panelGap - _minPanelHeight;
          final fixedHeight =
              _measure(
                context,
                _counterLabel,
                AutoFlowTokens.mono(color: tokens.mute),
                textWidth,
              ) +
              8 +
              8 +
              _measure(context, slide.body, bodyStyle, textWidth);
          var headlineStyle = _headlineStyle(tokens, layout.headlineSize);
          var textHeight =
              fixedHeight +
              _measure(context, slide.headline, headlineStyle, textWidth);
          while (textHeight > textBudget &&
              headlineStyle.fontSize! > _minHeadlineSize) {
            headlineStyle = _headlineStyle(tokens, headlineStyle.fontSize! - 2);
            textHeight =
                fixedHeight +
                _measure(context, slide.headline, headlineStyle, textWidth);
          }
          final panelHeight = (constraints.maxHeight - _panelGap - textHeight)
              .clamp(_minPanelHeight, layout.panelMaxHeight);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: panelHeight, child: _panel(context, tokens)),
              const SizedBox(height: _panelGap),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _text(tokens, headlineStyle, bodyStyle),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _measure(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final painter = TextPainter(
      // Merge like Text does, so inherited theme props (e.g. height) count.
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final height = painter.height;
    painter.dispose();
    return height;
  }

  Widget _panel(BuildContext context, AutoFlowTokens tokens) {
    return AnimatedOpacity(
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
            // The mock UI is decorative and already scaled to the panel, so
            // system text size shouldn't reflow it.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: MediaQuery.withNoTextScaling(child: _illustration()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(
    AutoFlowTokens tokens,
    TextStyle headlineStyle,
    TextStyle bodyStyle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AfReveal(
          visible: active,
          delayMs: 80,
          dy: 12,
          child: Text(
            _counterLabel,
            style: AutoFlowTokens.mono(color: tokens.mute),
          ),
        ),
        const SizedBox(height: 8),
        AfReveal(
          visible: active,
          delayMs: 140,
          dy: 12,
          child: Text(slide.headline, style: headlineStyle),
        ),
        const SizedBox(height: 8),
        AfReveal(
          visible: active,
          delayMs: 200,
          dy: 12,
          child: Text(slide.body, style: bodyStyle),
        ),
      ],
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
