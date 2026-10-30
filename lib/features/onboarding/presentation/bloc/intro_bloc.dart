import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/complete_onboarding.dart';
import 'intro_event.dart';
import 'intro_state.dart';

class IntroBloc extends Bloc<IntroEvent, IntroState> {
  final CompleteOnboarding _completeOnboarding;
  final Duration _startDelay;

  IntroBloc({
    required this._completeOnboarding,
    required int slideCount,
    int initialIndex = 0,
    this._startDelay = const Duration(milliseconds: 700),
  }) : super(IntroState(index: initialIndex, slideCount: slideCount)) {
    on<IntroPageChanged>(_onPageChanged);
    on<IntroDotTapped>(_onDotTapped);
    on<IntroNextPressed>(_onNextPressed);
    on<IntroSkipped>(_onSkipped);
  }

  void _onPageChanged(IntroPageChanged event, Emitter<IntroState> emit) {
    if (state.isStarting) return;
    emit(state.copyWith(index: event.index, status: IntroStatus.browsing));
  }

  void _onDotTapped(IntroDotTapped event, Emitter<IntroState> emit) {
    if (state.isStarting) return;
    final index = event.index.clamp(0, state.slideCount - 1);
    emit(state.copyWith(index: index, status: IntroStatus.browsing));
  }

  Future<void> _onNextPressed(
    IntroNextPressed event,
    Emitter<IntroState> emit,
  ) async {
    if (state.isStarting) return;
    if (!state.isLastSlide) {
      emit(
        state.copyWith(index: state.index + 1, status: IntroStatus.browsing),
      );
      return;
    }
    emit(state.copyWith(status: IntroStatus.starting));
    await Future.delayed(_startDelay);
    await _finish(emit);
  }

  Future<void> _onSkipped(IntroSkipped event, Emitter<IntroState> emit) async {
    if (state.isStarting) return;
    emit(state.copyWith(status: IntroStatus.starting));
    await _finish(emit);
  }

  // A failed write only means the intro shows again next launch, so the
  // failure is deliberately not surfaced.
  Future<void> _finish(Emitter<IntroState> emit) async {
    await _completeOnboarding(null);
    emit(state.copyWith(status: IntroStatus.finished));
  }
}
