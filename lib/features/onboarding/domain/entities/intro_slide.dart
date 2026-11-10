import 'package:equatable/equatable.dart';

enum IntroIllustration { highlights, inspection, photos }

class IntroSlide extends Equatable {
  final String headline;
  final String body;
  final IntroIllustration illustration;

  const IntroSlide({
    required this.headline,
    required this.body,
    required this.illustration,
  });

  @override
  List<Object?> get props => [headline, body, illustration];
}
