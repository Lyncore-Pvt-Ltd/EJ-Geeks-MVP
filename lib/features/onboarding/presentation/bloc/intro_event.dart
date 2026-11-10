import 'package:equatable/equatable.dart';

abstract class IntroEvent extends Equatable {
  const IntroEvent();

  @override
  List<Object?> get props => [];
}

/// The visible slide changed (swipe or programmatic scroll).
class IntroPageChanged extends IntroEvent {
  final int index;

  const IntroPageChanged(this.index);

  @override
  List<Object?> get props => [index];
}

/// A page dot was tapped.
class IntroDotTapped extends IntroEvent {
  final int index;

  const IntroDotTapped(this.index);

  @override
  List<Object?> get props => [index];
}

/// Next / Get started was pressed.
class IntroNextPressed extends IntroEvent {
  const IntroNextPressed();
}

class IntroSkipped extends IntroEvent {
  const IntroSkipped();
}
