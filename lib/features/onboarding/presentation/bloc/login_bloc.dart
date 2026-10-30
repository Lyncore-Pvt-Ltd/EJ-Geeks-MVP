import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_event.dart';
import 'login_state.dart';

const kInvalidEmailMessage = 'Enter a valid email address.';
const kShortPasswordMessage = 'Password is at least 8 characters.';
const kMagicLinkEmailMessage = 'Enter your email to get a magic link.';

/// UI-only login: validates the form and simulates the network round trip.
/// There is no auth backend yet (see `lib/features/auth/`).
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  static final _emailPattern = RegExp(r'^\S+@\S+\.\S+$');
  static const _minPasswordLength = 8;

  final Duration _latency;

  LoginBloc({this._latency = const Duration(milliseconds: 1100)})
    : super(const LoginState()) {
    on<LoginEmailChanged>(
      (event, emit) => emit(state.copyWith(email: event.email)),
    );
    on<LoginPasswordChanged>(
      (event, emit) => emit(state.copyWith(password: event.password)),
    );
    on<LoginPasswordVisibilityToggled>(
      (event, emit) => emit(state.copyWith(showPassword: !state.showPassword)),
    );
    on<LoginRememberToggled>(
      (event, emit) => emit(state.copyWith(remember: !state.remember)),
    );
    on<LoginSubmitted>(_onSubmitted);
    on<LoginMagicLinkRequested>(_onMagicLinkRequested);
    on<LoginReset>(
      (event, emit) => emit(
        state.copyWith(
          password: '',
          status: LoginStatus.idle,
          emailError: () => null,
          passwordError: () => null,
        ),
      ),
    );
  }

  bool get _emailIsValid => _emailPattern.hasMatch(state.email.trim());

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isBusy) return;
    final emailError = _emailIsValid ? null : kInvalidEmailMessage;
    final passwordError = state.password.length < _minPasswordLength
        ? kShortPasswordMessage
        : null;
    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          emailError: () => emailError,
          passwordError: () => passwordError,
          shakeCount: state.shakeCount + 1,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: LoginStatus.submitting,
        emailError: () => null,
        passwordError: () => null,
      ),
    );
    await Future.delayed(_latency);
    emit(
      state.copyWith(status: LoginStatus.success, method: LoginMethod.password),
    );
  }

  Future<void> _onMagicLinkRequested(
    LoginMagicLinkRequested event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isBusy) return;
    if (!_emailIsValid) {
      emit(
        state.copyWith(
          emailError: () => kMagicLinkEmailMessage,
          passwordError: () => null,
          shakeCount: state.shakeCount + 1,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: LoginStatus.sendingLink,
        emailError: () => null,
        passwordError: () => null,
      ),
    );
    await Future.delayed(_latency);
    emit(
      state.copyWith(
        status: LoginStatus.success,
        method: LoginMethod.magicLink,
      ),
    );
  }
}
