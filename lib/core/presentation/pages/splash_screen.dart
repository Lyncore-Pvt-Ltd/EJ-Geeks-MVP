import 'package:auto_flow/core/di/service_locator.dart';
import 'package:auto_flow/core/presentation/widgets/splash/animated_splash_icon.dart';
import 'package:auto_flow/core/presentation/widgets/splash/animated_splash_subtitle.dart';
import 'package:auto_flow/core/presentation/widgets/splash/animated_splash_title.dart';
import 'package:auto_flow/core/presentation/widgets/splash/splash_dots_indicator.dart';
import 'package:auto_flow/core/presentation/widgets/splash/splash_progress_bar.dart';
import 'package:auto_flow/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:auto_flow/features/onboarding/domain/usecases/is_onboarding_completed.dart';
import 'package:auto_flow/features/onboarding/presentation/pages/intro_page.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/auth/domain/usecases/get_current_session.dart';
import 'package:auto_flow/features/auth/presentation/session/session_controller.dart';
import 'package:auto_flow/features/onboarding/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const SplashScreen());

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _titleController;
  late final AnimationController _subtitleController;
  late final AnimationController _dotsController;
  late final AnimationController _progressController;

  late final Animation<double> _iconScaleAnimation;
  late final Animation<double> _iconFadeAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _subtitleFadeAnimation;
  late final Animation<Offset> _subtitleSlideAnimation;
  late final Animation<double> _dotsFadeAnimation;
  late final Animation<double> _progressAnimation;

  bool _hasNavigated = false;
  bool _started = false;

  /// Time from first frame to navigation. The entrance below finishes inside
  /// it; with reduced motion everything appears at once and we still hold.
  static const _totalMs = 1200;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(vsync: this);
    _iconScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: AutoFlowTokens.easeSpring,
      ),
    );
    _iconFadeAnimation = CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.0, 0.6, curve: AutoFlowTokens.easeOut),
    );

    _titleController = AnimationController(vsync: this);
    _titleFadeAnimation = CurvedAnimation(
      parent: _titleController,
      curve: AutoFlowTokens.easeOut,
    );
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _titleController,
            curve: AutoFlowTokens.easeOut,
          ),
        );

    _subtitleController = AnimationController(vsync: this);
    _subtitleFadeAnimation = CurvedAnimation(
      parent: _subtitleController,
      curve: AutoFlowTokens.easeOut,
    );
    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _subtitleController,
            curve: AutoFlowTokens.easeOut,
          ),
        );

    _dotsController = AnimationController(vsync: this);
    _dotsFadeAnimation = CurvedAnimation(
      parent: _dotsController,
      curve: AutoFlowTokens.easeOut,
    );

    _progressController = AnimationController(vsync: this);
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: AutoFlowTokens.easeOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // afDuration needs MediaQuery, which isn't readable in initState.
    if (_started) return;
    _started = true;
    _iconController.duration = afDuration(context, 420);
    _titleController.duration = afDuration(context, 320);
    _subtitleController.duration = afDuration(context, 320);
    _dotsController.duration = afDuration(context, 240);
    _progressController.duration = afDuration(context, _totalMs - 200);
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Navigation runs on its own clock so the hold is the same with or
    // without reduced motion.
    Future.delayed(const Duration(milliseconds: _totalMs), _navigateToHome);

    _iconController.forward();
    _progressController.forward();

    await Future.delayed(afDuration(context, 120));
    if (!mounted) return;
    _titleController.forward();

    await Future.delayed(afDuration(context, 80));
    if (!mounted) return;
    _subtitleController.forward();

    await Future.delayed(afDuration(context, 80));
    if (!mounted) return;
    _dotsController.forward();
  }

  Future<void> _navigateToHome() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    final result = await sl<IsOnboardingCompleted>()(null);
    if (!mounted) return;
    // A failed read falls back to showing the intro rather than blocking.
    final completed = result.getOrElse(() => false);
    final navigator = Navigator.of(context);
    if (!completed) {
      navigator.pushReplacement(IntroPage.route());
      return;
    }
    // Onboarded: a stored session goes straight to the dashboard, otherwise
    // the user must sign in.
    final sessionResult = await sl<GetCurrentSession>()(null);
    if (!mounted) return;
    final session = sessionResult.getOrElse(() => null);
    if (session == null) {
      navigator.pushReplacement(LoginPage.route());
      return;
    }
    context.read<SessionController>().setSession(session);
    navigator.pushReplacement(DashboardScreen.route());
  }

  @override
  void dispose() {
    _iconController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _dotsController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            AnimatedSplashIcon(
              scaleAnimation: _iconScaleAnimation,
              fadeAnimation: _iconFadeAnimation,
            ),
            const SizedBox(height: AfSpace.l24),
            AnimatedSplashTitle(
              fadeAnimation: _titleFadeAnimation,
              slideAnimation: _titleSlideAnimation,
            ),
            const SizedBox(height: AfSpace.s8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AfSpace.xl32),
              child: AnimatedSplashSubtitle(
                fadeAnimation: _subtitleFadeAnimation,
                slideAnimation: _subtitleSlideAnimation,
              ),
            ),
            const SizedBox(height: AfSpace.xl32),
            SplashDotsIndicator(fadeAnimation: _dotsFadeAnimation),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AfSpace.xxl48),
              child: SplashProgressBar(progressAnimation: _progressAnimation),
            ),
            const SizedBox(height: AfSpace.xxl48),
          ],
        ),
      ),
    );
  }
}
