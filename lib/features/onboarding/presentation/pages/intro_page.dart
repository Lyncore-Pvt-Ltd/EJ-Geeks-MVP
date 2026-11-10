import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/autoflow_tokens.dart';
import '../../data/constants/onboarding_content.dart';
import '../bloc/intro_bloc.dart';
import '../bloc/intro_event.dart';
import '../bloc/intro_state.dart';
import '../widgets/common/af_layout.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import '../widgets/intro/intro_footer.dart';
import '../widgets/intro/intro_header.dart';
import '../widgets/intro/intro_slide_view.dart';
import 'login_page.dart';

class IntroPage extends StatelessWidget {
  final int initialIndex;

  static MaterialPageRoute<dynamic> route({int initialIndex = 0}) =>
      MaterialPageRoute(builder: (_) => IntroPage(initialIndex: initialIndex));

  const IntroPage({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IntroBloc>(
      create: (_) => sl<IntroBloc>(param1: initialIndex),
      child: AfOnboardingFrame(child: _IntroView(initialIndex: initialIndex)),
    );
  }
}

class _IntroView extends StatefulWidget {
  final int initialIndex;

  const _IntroView({required this.initialIndex});

  @override
  State<_IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<_IntroView> {
  static const _tickPeriod = Duration(milliseconds: 1400);

  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  Timer? _ticker;

  /// Drives the looping illustrations; resets whenever the slide changes.
  /// Only the active illustration listens, so a tick doesn't rebuild the
  /// whole screen.
  final ValueNotifier<int> _tick = ValueNotifier(0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  /// Runs the tick only while this screen is visible and motion is allowed.
  /// TickerMode turns off once another opaque route (Log in) covers this one.
  void _syncTicker({bool restart = false}) {
    final shouldRun =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (!shouldRun || restart) {
      _ticker?.cancel();
      _ticker = null;
    }
    if (shouldRun && _ticker == null) {
      _ticker = Timer.periodic(_tickPeriod, (_) {
        if (!mounted) return;
        // Also skip while a route is pushing over this one.
        if (ModalRoute.of(context)?.isCurrent == false) return;
        _tick.value++;
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tick.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, IntroState state) {
    _tick.value = 0;
    // Give the new slide's first step a full period.
    _syncTicker(restart: true);
    final current = _pageController.hasClients
        ? _pageController.page?.round()
        : null;
    if (current != null && current != state.index) {
      _pageController.animateToPage(
        state.index,
        duration: afDuration(context, 450),
        curve: AutoFlowTokens.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return BlocConsumer<IntroBloc, IntroState>(
      listenWhen: (prev, curr) =>
          prev.index != curr.index || prev.status != curr.status,
      listener: (context, state) {
        if (state.status == IntroStatus.finished) {
          Navigator.of(context).push(LoginPage.route());
          return;
        }
        _onStateChanged(context, state);
      },
      builder: (context, state) {
        final bloc = context.read<IntroBloc>();
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: tokens.screenFor(MediaQuery.sizeOf(context).height),
            ),
            child: SafeArea(
              bottom: false,
              child: AfContentWidth(
                child: Column(
                  children: [
                    IntroHeader(onSkip: () => bloc.add(const IntroSkipped())),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: kIntroSlides.length,
                        onPageChanged: (i) => bloc.add(IntroPageChanged(i)),
                        itemBuilder: (context, i) => IntroSlideView(
                          slide: kIntroSlides[i],
                          index: i,
                          count: kIntroSlides.length,
                          active: i == state.index,
                          tick: _tick,
                        ),
                      ),
                    ),
                    // No bottom SafeArea: the footer pads itself to clear the
                    // nav bar / home indicator (afBottomInset).
                    IntroFooter(
                      count: kIntroSlides.length,
                      index: state.index,
                      starting: state.isStarting,
                      onDotSelected: (i) => bloc.add(IntroDotTapped(i)),
                      onNext: () => bloc.add(const IntroNextPressed()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
