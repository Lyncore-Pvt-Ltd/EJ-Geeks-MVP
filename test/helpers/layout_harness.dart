import 'package:auto_flow/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Portrait phones from iPhone SE (1st gen) to Pro Max, plus a tablet.
/// Same matrix as `test/features/onboarding/onboarding_layout_test.dart`.
const kLayoutSizes = <Size>[
  Size(320, 568),
  Size(360, 640),
  Size(375, 667),
  Size(390, 844),
  Size(412, 915),
  Size(430, 932),
  Size(768, 1024),
];

const kLayoutTextScales = [1.0, 1.3];

String layoutTag(Size size, double scale) =>
    '${size.width.toInt()}×${size.height.toInt()} @${scale}x';

/// Sets the fake view to [size] at [textScale] with notch/home-indicator
/// insets, and pumps [app] (which must contain its own `MaterialApp`, or use
/// [testApp]). Looping animations mean `pumpAndSettle` never would settle,
/// so this pumps a fixed duration instead.
Future<void> pumpAtSize(
  WidgetTester tester,
  Widget app, {
  required Size size,
  required double textScale,
  double bottomInset = 34,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = FakeViewPadding(top: 47, bottom: bottomInset);
  tester.view.viewPadding = FakeViewPadding(top: 47, bottom: bottomInset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(app);
  await settleFor(tester);
}

/// Pumps a few frames over [duration] so async loads and entrances land.
Future<void> settleFor(
  WidgetTester tester, [
  Duration duration = const Duration(seconds: 1),
]) async {
  const step = Duration(milliseconds: 100);
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(step);
    elapsed += step;
  }
}

/// `MaterialApp` with the app's light theme (which carries `AutoFlowTokens`).
Widget testApp(Widget home, {ThemeData? theme}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: theme ?? AppTheme.lightTheme,
  home: home,
);

/// Fails with the full overflow report if anything threw during layout.
void expectNoLayoutErrors(WidgetTester tester, String label) {
  final error = tester.takeException();
  expect(
    error,
    isNull,
    reason:
        '$label overflowed:\n${error is FlutterError ? error.toStringDeep() : error}',
  );
}

/// Drags [scrollable] towards its end in steps, checking for overflow after
/// each so lazily built children further down are laid out too.
Future<void> scrollThrough(
  WidgetTester tester,
  Finder scrollable,
  String label, {
  int maxSteps = 20,
}) async {
  for (var i = 0; i < maxSteps; i++) {
    final state = tester.state<ScrollableState>(scrollable);
    final position = state.position;
    if (position.pixels >= position.maxScrollExtent) break;
    position.jumpTo(
      (position.pixels + position.viewportDimension * 0.8).clamp(
        0,
        position.maxScrollExtent,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expectNoLayoutErrors(tester, '$label (scrolled to ${position.pixels})');
  }
}

/// Unmounts the tree so looping controllers/tickers are disposed.
Future<void> unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());
