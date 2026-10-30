import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  final String email;

  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

class LoginRememberToggled extends LoginEvent {
  const LoginRememberToggled();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginMagicLinkRequested extends LoginEvent {
  const LoginMagicLinkRequested();
}

/// Returns the form to idle after the success screen is dismissed.
class LoginReset extends LoginEvent {
  const LoginReset();
}
