import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../core/theme/autoflow_tokens.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';
import '../../data/constants/onboarding_content.dart';
import '../bloc/login_state.dart';
import '../widgets/common/af_layout.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_primary_button.dart';
import '../widgets/login/af_text_link.dart';
import '../widgets/success/success_tick.dart';
import '../widgets/success/today_summary_card.dart';
import 'intro_page.dart';

/// Peak-and-end moment after logging in (or requesting a magic link).
class OnboardingSuccessPage extends StatefulWidget {
  final LoginMethod method;
  final String email;

  static MaterialPageRoute<dynamic> route({
    required LoginMethod method,
    required String email,
  }) => MaterialPageRoute(
    builder: (_) => OnboardingSuccessPage(method: method, email: email),
  );

  const OnboardingSuccessPage({
    super.key,
    required this.method,
    required this.email,
  });

  @override
  State<OnboardingSuccessPage> createState() => _OnboardingSuccessPageState();
}

class _OnboardingSuccessPageState extends State<OnboardingSuccessPage> {
  /// Guards against a double tap while the route transition runs.
  bool _navigating = false;

  bool get _isMagic => widget.method == LoginMethod.magicLink;

  String get _headline => _isMagic ? 'Check your inbox.' : 'Welcome back.';

  String get _subline => _isMagic
      ? 'We sent a magic link to ${widget.email}.'
      : 'Here’s your workshop at a glance.';

  @override
  void initState() {
    super.initState();
    // Screen readers hear the outcome without hunting for it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SemanticsService.sendAnnouncement(
        View.of(context),
        '$_headline $_subline',
        Directionality.of(context),
      );
    });
  }

  void _onCta() {
    if (_navigating) return;
    _navigating = true;
    final navigator = Navigator.of(context);
    if (_isMagic) {
      // No mail-app integration yet: return to the login form.
      navigator.pop();
    } else {
      navigator.pushAndRemoveUntil(DashboardScreen.route(), (_) => false);
    }
  }

  void _replayIntro() {
    Navigator.of(context).pushAndRemoveUntil(IntroPage.route(), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final layout = AfLayout.of(context);
    final headlineStyle = AutoFlowTokens.headline.copyWith(
      fontSize: layout.headlineSize,
      letterSpacing: -0.03 * layout.headlineSize,
      color: Colors.white,
    );
    return AfOnboardingFrame(child: _scaffold(layout, headlineStyle));
  }

  Widget _scaffold(AfLayout layout, TextStyle headlineStyle) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AutoFlowTokens.celebration),
        child: SafeArea(
          bottom: false,
          child: AfContentWidth(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      // Vertical room so the tick's sparks and glow aren't
                      // clipped by the scroll view.
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: layout.isCompact ? 32 : 48,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(child: SuccessTick()),
                          SizedBox(height: layout.isCompact ? 12 : 16),
                          AfReveal(
                            visible: true,
                            delayMs: 250,
                            child: Semantics(
                              header: true,
                              child: Text(
                                _headline,
                                textAlign: TextAlign.center,
                                style: headlineStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AfReveal(
                            visible: true,
                            delayMs: 320,
                            child: Text(
                              _subline,
                              textAlign: TextAlign.center,
                              style: AutoFlowTokens.body.copyWith(
                                color: const Color(0xFFE5E5E5),
                              ),
                            ),
                          ),
                          if (!_isMagic) ...[
                            SizedBox(height: layout.sectionGap),
                            AfReveal(
                              visible: true,
                              delayMs: 400,
                              child: TodaySummaryCard(
                                rows: kTodaySummary,
                                rowHeight: layout.isCompact ? 44 : 48,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                AfReveal(
                  visible: true,
                  delayMs: 480,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      layout.isCompact ? 8 : 16,
                      16,
                      afBottomInset(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AfPrimaryButton(
                          label: _isMagic
                              ? 'Open mail app'
                              : 'Go to today’s jobs',
                          borderColor: const Color(0x1FFFFFFF),
                          onPressed: _onCta,
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: AfTextLink(
                            label: 'Replay intro',
                            color: const Color(0xB8E5E5E5),
                            onTap: _replayIntro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
