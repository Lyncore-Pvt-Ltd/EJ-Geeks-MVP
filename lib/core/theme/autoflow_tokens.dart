import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export 'af_dimens.dart';

/// AutoFlow design tokens (see DESIGN.md). Theme-dependent values live on the
/// extension instance; theme-independent ones are static.
@immutable
class AutoFlowTokens extends ThemeExtension<AutoFlowTokens> {
  final Color ink;
  final Color navy;
  final Color line;
  final Color soft;
  final Color hot;
  final Color mute;
  final Color mute2;
  final Color card;
  final LinearGradient page;
  final LinearGradient screen;
  final LinearGradient panel;

  const AutoFlowTokens({
    required this.ink,
    required this.navy,
    required this.line,
    required this.soft,
    required this.hot,
    required this.mute,
    required this.mute2,
    required this.card,
    required this.page,
    required this.screen,
    required this.panel,
  });

  static const Color accent = Color(0xFFFCA311);
  static const Color onAccent = Color(0xFF000000);
  static const Color navyInk = Color(0xFF14213D);
  static const Color successFg = Color(0xFF007F35);
  static const Color successBg = Color(0xFFE4FBE7);
  static const Color warningFg = Color(0xFF945A00);
  static const Color warningBg = Color(0xFFFFF0D6);
  static const Color errorFg = Color(0xFFAF3D36);
  static const Color errorBg = Color(0xFFFFECE9);

  static const Curve easeOut = Cubic(0.23, 1, 0.32, 1);
  static const Curve easeSpring = Cubic(0.34, 1.56, 0.64, 1);

  /// `radial-gradient(120% 45% at 50% 0%, ...)`: an ellipse 120% of the
  /// width across and 45% of the height down, centred on the top edge.
  static const RadialGradient celebration = RadialGradient(
    center: Alignment.topCenter,
    // Radius 1 = the shortest side; the transform stretches it per axis.
    radius: 1,
    colors: [accent, navyInk, Color(0xFF000000)],
    stops: [0, 0.5, 1],
    transform: AfEllipticalGradientTransform(
      widthFactor: 1.2,
      heightFactor: 0.45,
    ),
  );

  /// Height (px) at which the [page] gradient reaches its end colour.
  static const double pageGradientExtent = 420;

  /// Height (px) at which the [screen] gradient reaches its end colour.
  static const double screenGradientExtent = 320;

  /// [page] with its end stop fixed at 420px for a box [height] px tall
  /// (DESIGN.md: `linear-gradient(180deg, a 0%, b 420px)`).
  LinearGradient pageFor(double height) =>
      _fixedExtent(page, pageGradientExtent, height);

  /// [screen] with its end stop fixed at 320px for a box [height] px tall.
  LinearGradient screenFor(double height) =>
      _fixedExtent(screen, screenGradientExtent, height);

  static LinearGradient _fixedExtent(
    LinearGradient base,
    double extent,
    double height,
  ) {
    final stop = height <= 0 ? 1.0 : (extent / height).clamp(0.0, 1.0);
    return LinearGradient(
      begin: base.begin,
      end: base.end,
      colors: [base.colors.first, base.colors.last],
      stops: [0, stop],
    );
  }

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x2E14213D),
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: -16,
    ),
  ];
  static const List<BoxShadow> heroShadow = [
    BoxShadow(
      color: Color(0x5914213D),
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: -12,
    ),
  ];
  static const List<BoxShadow> accentShadow = [
    BoxShadow(
      color: Color(0x8CFCA311),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -8,
    ),
  ];
  static const List<BoxShadow> footerShadow = [
    BoxShadow(color: Color(0x1A14213D), offset: Offset(0, 1), blurRadius: 10),
  ];

  static const String fontFamily = 'Satoshi';

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.84,
  );
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.17,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mono({double fontSize = 13, Color? color}) =>
      GoogleFonts.fragmentMono(
        fontSize: fontSize,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static const light = AutoFlowTokens(
    ink: navyInk,
    navy: navyInk,
    line: Color(0xFFE5E5E5),
    soft: Color(0xFFF4F4F4),
    hot: Color(0xFFFFF7EA),
    mute: Color(0xA314213D),
    mute2: Color(0xB814213D),
    card: Color(0xFFFFFFFF),
    page: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE5E5E5), Color(0xFFFFFFFF)],
      stops: [0, 0.5],
    ),
    screen: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE5E5E5), Color(0xFFFFFFFF)],
      stops: [0, 0.38],
    ),
    panel: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE5E5E5), Color(0xFFFFFFFF)],
    ),
  );

  static const dark = AutoFlowTokens(
    ink: Color(0xFFFFFFFF),
    navy: Color(0xFF1F3260),
    line: Color(0x24E5E5E5),
    soft: Color(0x14E5E5E5),
    hot: Color(0x1FFCA311),
    mute: Color(0xA3E5E5E5),
    mute2: Color(0xC7E5E5E5),
    card: Color(0xFF0F1A30),
    page: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [navyInk, Color(0xFF000000)],
      stops: [0, 0.5],
    ),
    screen: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [navyInk, Color(0xFF000000)],
      stops: [0, 0.38],
    ),
    panel: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [navyInk, Color(0xFF0A1120)],
    ),
  );

  static AutoFlowTokens of(BuildContext context) =>
      Theme.of(context).extension<AutoFlowTokens>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  AutoFlowTokens copyWith({
    Color? ink,
    Color? navy,
    Color? line,
    Color? soft,
    Color? hot,
    Color? mute,
    Color? mute2,
    Color? card,
    LinearGradient? page,
    LinearGradient? screen,
    LinearGradient? panel,
  }) {
    return AutoFlowTokens(
      ink: ink ?? this.ink,
      navy: navy ?? this.navy,
      line: line ?? this.line,
      soft: soft ?? this.soft,
      hot: hot ?? this.hot,
      mute: mute ?? this.mute,
      mute2: mute2 ?? this.mute2,
      card: card ?? this.card,
      page: page ?? this.page,
      screen: screen ?? this.screen,
      panel: panel ?? this.panel,
    );
  }

  @override
  AutoFlowTokens lerp(AutoFlowTokens? other, double t) {
    if (other == null) return this;
    return AutoFlowTokens(
      ink: Color.lerp(ink, other.ink, t)!,
      navy: Color.lerp(navy, other.navy, t)!,
      line: Color.lerp(line, other.line, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
      hot: Color.lerp(hot, other.hot, t)!,
      mute: Color.lerp(mute, other.mute, t)!,
      mute2: Color.lerp(mute2, other.mute2, t)!,
      card: Color.lerp(card, other.card, t)!,
      page: LinearGradient.lerp(page, other.page, t)!,
      screen: LinearGradient.lerp(screen, other.screen, t)!,
      panel: LinearGradient.lerp(panel, other.panel, t)!,
    );
  }
}

/// Turns a circular [RadialGradient] (radius 1 = the shortest side, centred
/// at its `center`) into an ellipse whose radii are [widthFactor] × the box
/// width and [heightFactor] × the box height, like CSS `radial-gradient(W% H%)`.
/// Assumes the gradient's centre is [Alignment.topCenter].
class AfEllipticalGradientTransform extends GradientTransform {
  final double widthFactor;
  final double heightFactor;

  const AfEllipticalGradientTransform({
    required this.widthFactor,
    required this.heightFactor,
  });

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final shortest = bounds.shortestSide;
    if (shortest <= 0) return Matrix4.identity();
    final cx = bounds.center.dx;
    final cy = bounds.top;
    return Matrix4.identity()
      ..translateByDouble(cx, cy, 0, 1)
      ..scaleByDouble(
        bounds.width * widthFactor / shortest,
        bounds.height * heightFactor / shortest,
        1,
        1,
      )
      ..translateByDouble(-cx, -cy, 0, 1);
  }
}
