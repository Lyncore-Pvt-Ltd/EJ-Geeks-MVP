import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AfSize { compact, regular, large }

/// Phone-size buckets for the onboarding screens (portrait only).
/// compact: SE / 360×640-class; large: 412×915 and up; regular in between.
class AfLayout {
  final AfSize size;
  final Size screen;

  const AfLayout._(this.size, this.screen);

  /// Widest the content column grows to; tablets get a centred phone column.
  static const double maxContentWidth = 480;

  factory AfLayout.of(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final AfSize size;
    if (screen.width < 360 || screen.height < 700) {
      size = AfSize.compact;
    } else if (screen.width >= 412 && screen.height >= 860) {
      size = AfSize.large;
    } else {
      size = AfSize.regular;
    }
    return AfLayout._(size, screen);
  }

  bool get isCompact => size == AfSize.compact;

  double get headlineSize => switch (size) {
    AfSize.compact => 24,
    AfSize.regular => 28,
    AfSize.large => 30,
  };

  double get panelMaxHeight => switch (size) {
    AfSize.compact => math.max(180, screen.height * 0.4),
    AfSize.regular => 340,
    AfSize.large => 380,
  };

  /// Gap between unrelated groups (24 per DESIGN.md, tightened on compact).
  double get sectionGap => isCompact ? 16 : 24;
}

/// Footer bottom padding: the design's 32px, but never less than the system
/// nav bar / home indicator inset plus 16px.
double afBottomInset(BuildContext context, {double base = 32}) =>
    math.max(base, MediaQuery.viewPaddingOf(context).bottom + 16);

/// Centres [child] in a column no wider than [AfLayout.maxContentWidth].
class AfContentWidth extends StatelessWidget {
  final Widget child;

  const AfContentWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AfLayout.maxContentWidth),
        child: child,
      ),
    );
  }
}

/// Shared wrapper for every onboarding page: locks portrait while any
/// onboarding page is mounted and caps text scaling at 1.3× so fixed-height
/// controls (48px fields/buttons) can't break.
class AfOnboardingFrame extends StatefulWidget {
  final Widget child;

  const AfOnboardingFrame({super.key, required this.child});

  @override
  State<AfOnboardingFrame> createState() => _AfOnboardingFrameState();
}

class _AfOnboardingFrameState extends State<AfOnboardingFrame> {
  // Intro and login stack on the navigator, so the lock is ref-counted and
  // only released when the last onboarding page goes away.
  static int _mounted = 0;

  @override
  void initState() {
    super.initState();
    if (_mounted++ == 0) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void dispose() {
    if (--_mounted == 0) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: widget.child,
    );
  }
}
