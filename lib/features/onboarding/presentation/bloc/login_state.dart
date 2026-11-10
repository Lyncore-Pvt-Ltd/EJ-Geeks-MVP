import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/auth_session.dart';

enum LoginStatus { idle, submitting, sendingLink, success, failure }

enum LoginMethod { password, magicLink }

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool showPassword;
  final bool remember;
  final String? emailError;
  final String? passwordError;
  final LoginStatus status;
  final LoginMethod method;

  /// Server/network error shown under the form after a failed sign-in.
  final String? errorMessage;

  /// Set once password sign-in succeeds.
  final AuthSession? session;

  /// Bumped on every failed validation so the page can shake the form even
  /// when the error text itself didn't change.
  final int shakeCount;

  const LoginState({
    this.email = '',
    this.password = '',
    this.showPassword = false,
    this.remember = true,
    this.emailError,
    this.passwordError,
    this.status = LoginStatus.idle,
    this.method = LoginMethod.password,
    this.errorMessage,
    this.session,
    this.shakeCount = 0,
  });

  bool get isBusy =>
      status == LoginStatus.submitting || status == LoginStatus.sendingLink;

  LoginState copyWith({
    String? email,
    String? password,
    bool? showPassword,
    bool? remember,
    String? Function()? emailError,
    String? Function()? passwordError,
    LoginStatus? status,
    LoginMethod? method,
    String? Function()? errorMessage,
    AuthSession? session,
    int? shakeCount,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      showPassword: showPassword ?? this.showPassword,
      remember: remember ?? this.remember,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null
          ? passwordError()
          : this.passwordError,
      status: status ?? this.status,
      method: method ?? this.method,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      session: session ?? this.session,
      shakeCount: shakeCount ?? this.shakeCount,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    showPassword,
    remember,
    emailError,
    passwordError,
    status,
    method,
    errorMessage,
    session,
    shakeCount,
  ];
}
