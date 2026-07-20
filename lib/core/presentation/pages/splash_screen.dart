import 'package:ej_geek/core/presentation/widgets/splash/animated_splash_icon.dart';
import 'package:ej_geek/core/presentation/widgets/splash/animated_splash_subtitle.dart';
import 'package:ej_geek/core/presentation/widgets/splash/animated_splash_title.dart';
import 'package:ej_geek/core/presentation/widgets/splash/splash_dots_indicator.dart';
import 'package:ej_geek/core/presentation/widgets/splash/splash_progress_bar.dart';
import 'package:ej_geek/features/invoice/presentation/pages/invoice_screen.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeIn));
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );

    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );
    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _subtitleController,
            curve: Curves.easeOutCubic,
          ),
        );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dotsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _dotsController, curve: Curves.easeIn));

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _iconController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _subtitleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _dotsController.forward();
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    _navigateToHome();
  }

  void _navigateToHome() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacement(InvoiceScreen.route());
    }
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
            const SizedBox(height: 30),
            AnimatedSplashTitle(
              fadeAnimation: _titleFadeAnimation,
              slideAnimation: _titleSlideAnimation,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedSplashSubtitle(
                fadeAnimation: _subtitleFadeAnimation,
                slideAnimation: _subtitleSlideAnimation,
              ),
            ),
            const SizedBox(height: 40),
            SplashDotsIndicator(fadeAnimation: _dotsFadeAnimation),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: SplashProgressBar(progressAnimation: _progressAnimation),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
