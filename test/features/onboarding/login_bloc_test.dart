import 'package:auto_flow/core/error/failures.dart';
import 'package:auto_flow/features/auth/domain/entities/auth_session.dart';
import 'package:auto_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:auto_flow/features/auth/domain/usecases/login_user.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/login_bloc.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/login_event.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/login_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

const _session = AuthSession(
  user: AuthUser(id: '1', email: 'sam@northsideauto.com', fullName: 'Sam'),
  roles: [],
);

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this.result);
  final Either<Failure, AuthSession> result;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
    required bool remember,
  }) async => result;

  @override
  Future<Either<Failure, AuthSession?>> getCurrentSession() async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Stream<void> get sessionExpired => const Stream.empty();
}

void main() {
  late LoginBloc bloc;

  LoginBloc build(Either<Failure, AuthSession> result) => LoginBloc(
    loginUser: LoginUser(_StubAuthRepository(result)),
    magicLinkLatency: Duration.zero,
  );

  setUp(() => bloc = build(const Right(_session)));
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
    expect(state.session, _session);
  });

  test('rejected credentials surface the failure message', () async {
    await bloc.close();
    bloc = build(const Left(AuthFailure(message: 'Invalid credentials.')));
    bloc
      ..add(const LoginEmailChanged('sam@northsideauto.com'))
      ..add(const LoginPasswordChanged('hunter22'))
      ..add(const LoginSubmitted());
    final state = await settle();

    expect(state.status, LoginStatus.failure);
    expect(state.errorMessage, 'Invalid credentials.');
    expect(state.shakeCount, 1);
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
