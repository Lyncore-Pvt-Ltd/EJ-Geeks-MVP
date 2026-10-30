import 'package:auto_flow/core/di/service_locator.dart';
import 'package:auto_flow/core/error/failures.dart';
import 'package:auto_flow/core/theme/theme.dart';
import 'package:auto_flow/features/onboarding/data/constants/onboarding_content.dart';
import 'package:auto_flow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:auto_flow/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/intro_bloc.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/login_bloc.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/login_state.dart';
import 'package:auto_flow/features/onboarding/presentation/pages/intro_page.dart';
import 'package:auto_flow/features/onboarding/presentation/pages/login_page.dart';
import 'package:auto_flow/features/onboarding/presentation/pages/onboarding_success_page.dart';
import 'package:auto_flow/features/onboarding/presentation/widgets/intro/intro_slide_view.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<Either<Failure, void>> completeOnboarding() async => const Right(null);

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() async =>
      const Right(false);
}

/// Portrait phones from iPhone SE (1st gen) to Pro Max, plus a tablet.
const _sizes = <Size>[
  Size(320, 568),
  Size(360, 640),
  Size(375, 667),
  Size(390, 844),
  Size(412, 915),
  Size(430, 932),
  Size(768, 1024),
];

const _textScales = [1.0, 1.3];

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await sl.reset();
    sl.registerFactoryParam<IntroBloc, int, void>(
      (initialIndex, _) => IntroBloc(
        completeOnboarding: CompleteOnboarding(_FakeOnboardingRepository()),
        slideCount: kIntroSlides.length,
        initialIndex: initialIndex,
      ),
    );
    sl.registerFactory<LoginBloc>(() => LoginBloc(latency: Duration.zero));
  });

  Future<void> pumpAt(
    WidgetTester tester,
    Widget page, {
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

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: page),
    );
    // Let entrances finish; looping animations mean pumpAndSettle never would.
    await tester.pump(const Duration(seconds: 2));
  }

  /// Fails on any layout overflow and checks the CTA clears the bottom inset.
  void expectFits(
    WidgetTester tester,
    Finder cta, {
    required Size size,
    required double bottomInset,
    required String label,
  }) {
    final error = tester.takeException();
    expect(
      error,
      isNull,
      reason:
          '$label overflowed:\n${error is FlutterError ? error.toStringDeep() : error}',
    );
    final rect = tester.getRect(cta.first);
    expect(
      rect.bottom,
      lessThanOrEqualTo(size.height - bottomInset),
      reason: '$label CTA sits under the system inset',
    );
    expect(rect.left, greaterThanOrEqualTo(0), reason: '$label CTA clipped');
    expect(
      rect.right,
      lessThanOrEqualTo(size.width),
      reason: '$label CTA clipped',
    );
  }

  Future<void> unmount(WidgetTester tester) async {
    // Disposes the intro ticker and looping controllers.
    await tester.pumpWidget(const SizedBox());
  }

  for (final size in _sizes) {
    for (final scale in _textScales) {
      final tag = '${size.width.toInt()}×${size.height.toInt()} @${scale}x';

      testWidgets('intro slides fit at $tag', (tester) async {
        for (var i = 0; i < kIntroSlides.length; i++) {
          await pumpAt(
            tester,
            IntroPage(initialIndex: i),
            size: size,
            textScale: scale,
          );
          final isLast = i == kIntroSlides.length - 1;
          expectFits(
            tester,
            find.text(isLast ? 'Get started' : 'Next'),
            size: size,
            bottomInset: 34,
            label: 'slide ${i + 1}',
          );
          // Compact (SE-class) screens keep the scroll fallback.
          if (scale == 1.0 && size.height >= 700) {
            final textScroll = tester.state<ScrollableState>(
              find.descendant(
                of: find.byWidgetPredicate(
                  (w) => w is IntroSlideView && w.active,
                ),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is Scrollable && w.axisDirection == AxisDirection.down,
                ),
              ),
            );
            expect(
              textScroll.position.maxScrollExtent,
              0,
              reason: 'slide ${i + 1} text scrolls instead of fitting',
            );
          }
          await unmount(tester);
        }
      });

      testWidgets('login fits with errors at $tag', (tester) async {
        await pumpAt(tester, const LoginPage(), size: size, textScale: scale);
        await tester.tap(find.text('Log in'));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text(kInvalidEmailMessage), findsOneWidget);
        expectFits(
          tester,
          find.text('Log in'),
          size: size,
          bottomInset: 34,
          label: 'login',
        );
        await unmount(tester);
      });

      testWidgets('success screens fit at $tag', (tester) async {
        for (final method in LoginMethod.values) {
          await pumpAt(
            tester,
            OnboardingSuccessPage(
              method: method,
              email: 'sam@northsideauto.com',
            ),
            size: size,
            textScale: scale,
          );
          expectFits(
            tester,
            find.text(
              method == LoginMethod.password
                  ? 'Go to today’s jobs'
                  : 'Open mail app',
            ),
            size: size,
            bottomInset: 34,
            label: 'success (${method.name})',
          );
          await unmount(tester);
        }
      });
    }
  }

  testWidgets('footers clear a 48px Android 3-button nav bar', (tester) async {
    const size = Size(360, 640);
    await pumpAt(
      tester,
      const IntroPage(),
      size: size,
      textScale: 1,
      bottomInset: 48,
    );
    expectFits(
      tester,
      find.text('Next'),
      size: size,
      bottomInset: 48,
      label: 'intro',
    );
    await unmount(tester);

    await pumpAt(
      tester,
      const LoginPage(),
      size: size,
      textScale: 1,
      bottomInset: 48,
    );
    expectFits(
      tester,
      find.text('Log in'),
      size: size,
      bottomInset: 48,
      label: 'login',
    );
    await unmount(tester);
  });
}
