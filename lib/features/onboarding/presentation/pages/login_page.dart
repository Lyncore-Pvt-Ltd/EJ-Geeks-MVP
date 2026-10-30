import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/autoflow_tokens.dart';
import '../../data/constants/onboarding_content.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../widgets/common/af_icon_button.dart';
import '../widgets/common/af_layout.dart';
import '../widgets/common/af_logo_mark.dart';
import '../widgets/common/af_motion.dart';
import '../widgets/common/af_primary_button.dart';
import '../widgets/common/af_secondary_button.dart';
import '../widgets/common/af_text_field.dart';
import '../widgets/login/af_text_link.dart';
import '../widgets/login/or_divider.dart';
import '../widgets/login/remember_checkbox.dart';
import 'intro_page.dart';
import 'onboarding_success_page.dart';

class LoginPage extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (_) => const LoginPage());

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => sl<LoginBloc>(),
      child: const AfOnboardingFrame(child: _LoginView()),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _back() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        IntroPage.route(initialIndex: kIntroSlides.length - 1),
      );
    }
  }

  Future<void> _openSuccess(LoginState state) async {
    final bloc = context.read<LoginBloc>();
    await Navigator.of(context).push(
      OnboardingSuccessPage.route(method: state.method, email: state.email),
    );
    // Back from the success screen (or "Open mail app") returns to a clean
    // form rather than a stuck "success" state.
    _passwordController.clear();
    bloc.add(const LoginReset());
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return BlocConsumer<LoginBloc, LoginState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status && curr.status == LoginStatus.success,
      listener: (context, state) => _openSuccess(state),
      builder: (context, state) {
        final bloc = context.read<LoginBloc>();
        final layout = AfLayout.of(context);
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(gradient: tokens.screen),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AfContentWidth(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      alignment: Alignment.centerLeft,
                      child: AfIconButton(
                        icon: Icons.chevron_left_rounded,
                        semanticLabel: 'Back',
                        onPressed: _back,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        layout.isCompact ? 8 : 16,
                        16,
                        layout.sectionGap,
                      ),
                      child: AfContentWidth(
                        child: _form(context, state, bloc, tokens, layout),
                      ),
                    ),
                  ),
                  AfReveal(
                    visible: true,
                    delayMs: 200,
                    child: Container(
                      // With the keyboard up it already covers the system
                      // inset, so the footer only needs a small gap.
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        keyboardOpen ? 16 : afBottomInset(context),
                      ),
                      decoration: BoxDecoration(
                        color: tokens.screen.colors.last,
                        boxShadow: AutoFlowTokens.footerShadow,
                      ),
                      child: AfContentWidth(
                        child: AfPrimaryButton(
                          label: 'Log in',
                          busyLabel: 'Signing in…',
                          showArrow: true,
                          busy: state.status == LoginStatus.submitting,
                          onPressed: () => bloc.add(const LoginSubmitted()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _form(
    BuildContext context,
    LoginState state,
    LoginBloc bloc,
    AutoFlowTokens tokens,
    AfLayout layout,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AfReveal(
          visible: true,
          child: Padding(
            padding: EdgeInsets.only(top: layout.isCompact ? 0 : 8),
            child: Column(
              children: [
                const AfLogoMark(size: 56, glow: true),
                const SizedBox(height: 12),
                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: AutoFlowTokens.headline.copyWith(
                    color: tokens.ink,
                    fontSize: layout.headlineSize,
                    letterSpacing: -0.03 * layout.headlineSize,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Log in to your workshop.',
                  textAlign: TextAlign.center,
                  style: AutoFlowTokens.body.copyWith(color: tokens.mute2),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: layout.sectionGap),
        AfReveal(
          visible: true,
          delayMs: 60,
          child: AfShake(
            trigger: state.shakeCount,
            child: AnimatedOpacity(
              opacity: state.isBusy ? 0.55 : 1,
              duration: afDuration(context, 200),
              child: AbsorbPointer(
                absorbing: state.isBusy,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AfTextField(
                        label: 'Work email',
                        hint: 'sam@northsideauto.com',
                        controller: _emailController,
                        errorText: state.emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onChanged: (v) => bloc.add(LoginEmailChanged(v)),
                      ),
                      const SizedBox(height: 16),
                      AfTextField(
                        label: 'Password',
                        hint: 'Your password',
                        controller: _passwordController,
                        errorText: state.passwordError,
                        obscureText: !state.showPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onChanged: (v) => bloc.add(LoginPasswordChanged(v)),
                        onSubmitted: (_) => bloc.add(const LoginSubmitted()),
                        trailing: IconButton(
                          tooltip: state.showPassword
                              ? 'Hide password'
                              : 'Show password',
                          onPressed: () =>
                              bloc.add(const LoginPasswordVisibilityToggled()),
                          icon: Icon(
                            state.showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: tokens.mute,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        // Wraps onto two lines on narrow phones / big text.
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            RememberCheckbox(
                              value: state.remember,
                              onToggle: () =>
                                  bloc.add(const LoginRememberToggled()),
                            ),
                            // No password-reset flow exists yet.
                            AfTextLink(label: 'Forgot password?', onTap: () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: layout.sectionGap),
        const AfReveal(visible: true, delayMs: 120, child: OrDivider()),
        SizedBox(height: layout.sectionGap),
        AfReveal(
          visible: true,
          delayMs: 150,
          child: AfSecondaryButton(
            label: 'Email me a magic link',
            busyLabel: 'Sending link…',
            icon: Icons.mail_outline_rounded,
            busy: state.status == LoginStatus.sendingLink,
            onPressed: () => bloc.add(const LoginMagicLinkRequested()),
          ),
        ),
        SizedBox(height: layout.sectionGap),
        AfReveal(
          visible: true,
          delayMs: 180,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'New to AutoFlow? ',
                style: AutoFlowTokens.caption.copyWith(color: tokens.mute2),
              ),
              // No sign-up flow exists yet.
              AfTextLink(
                label: 'Start your free 14-day trial',
                fontWeight: FontWeight.w500,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
