import 'package:auto_flow/features/onboarding/presentation/bloc/login_bloc.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/login_event.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LoginBloc bloc;

  setUp(() => bloc = LoginBloc(latency: Duration.zero));
  tearDown(() => bloc.close());

  Future<LoginState> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return bloc.state;
  }

  test('submitting an empty form shows both errors and shakes', () async {
    bloc.add(const LoginSubmitted());
    final state = await settle();

    expect(state.emailError, kInvalidEmailMessage);
    expect(state.passwordError, kShortPasswordMessage);
    expect(state.shakeCount, 1);
    expect(state.status, LoginStatus.idle);
  });

  test('valid credentials end in password success', () async {
    bloc
      ..add(const LoginEmailChanged('sam@northsideauto.com'))
      ..add(const LoginPasswordChanged('hunter22'))
      ..add(const LoginSubmitted());
    final state = await settle();

    expect(state.emailError, isNull);
    expect(state.passwordError, isNull);
    expect(state.status, LoginStatus.success);
    expect(state.method, LoginMethod.password);
  });

  test('magic link without an email asks for one', () async {
    bloc.add(const LoginMagicLinkRequested());
    final state = await settle();

    expect(state.emailError, kMagicLinkEmailMessage);
    expect(state.passwordError, isNull);
    expect(state.status, LoginStatus.idle);
  });

  test('magic link with a valid email ends in magic-link success', () async {
    bloc
      ..add(const LoginEmailChanged('sam@northsideauto.com'))
      ..add(const LoginMagicLinkRequested());
    final state = await settle();

    expect(state.status, LoginStatus.success);
    expect(state.method, LoginMethod.magicLink);
  });

  test('reset clears password, errors and status', () async {
    bloc
      ..add(const LoginEmailChanged('sam@northsideauto.com'))
      ..add(const LoginPasswordChanged('hunter22'))
      ..add(const LoginSubmitted());
    await settle();
    bloc.add(const LoginReset());
    final state = await settle();

    expect(state.password, isEmpty);
    expect(state.email, 'sam@northsideauto.com');
    expect(state.status, LoginStatus.idle);
  });
}
