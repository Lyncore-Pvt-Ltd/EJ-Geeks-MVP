import 'package:equatable/equatable.dart';

enum IntroStatus { browsing, starting, finished }

class IntroState extends Equatable {
  final int index;
  final int slideCount;
  final IntroStatus status;

  const IntroState({
    this.index = 0,
    required this.slideCount,
    this.status = IntroStatus.browsing,
  });

  bool get isLastSlide => index == slideCount - 1;
  bool get isStarting => status == IntroStatus.starting;

  IntroState copyWith({int? index, IntroStatus? status}) {
    return IntroState(
      index: index ?? this.index,
      slideCount: slideCount,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [index, slideCount, status];
}
