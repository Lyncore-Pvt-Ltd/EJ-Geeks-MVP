import 'package:auto_flow/core/error/failures.dart';
import 'package:auto_flow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:auto_flow/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/intro_bloc.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/intro_event.dart';
import 'package:auto_flow/features/onboarding/presentation/bloc/intro_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  bool completed = false;

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    completed = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() async =>
      Right(completed);
}

void main() {
  late _FakeOnboardingRepository repository;
  late IntroBloc bloc;

  setUp(() {
    repository = _FakeOnboardingRepository();
    bloc = IntroBloc(
      completeOnboarding: CompleteOnboarding(repository),
      slideCount: 3,
      startDelay: Duration.zero,
    );
  });
  tearDown(() => bloc.close());

  Future<IntroState> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return bloc.state;
  }

  test(
    'next advances slides, then finishes and persists on the last',
    () async {
      bloc.add(const IntroNextPressed());
      expect((await settle()).index, 1);
      bloc.add(const IntroNextPressed());
      expect((await settle()).index, 2);
      expect(repository.completed, isFalse);

      bloc.add(const IntroNextPressed());
      final state = await settle();
      expect(state.status, IntroStatus.finished);
      expect(repository.completed, isTrue);
    },
  );

  test('skip finishes from any slide', () async {
    bloc.add(const IntroSkipped());
    final state = await settle();

    expect(state.index, 0);
    expect(state.status, IntroStatus.finished);
    expect(repository.completed, isTrue);
  });

  test('dot taps are clamped to the slide range', () async {
    bloc.add(const IntroDotTapped(9));
    expect((await settle()).index, 2);
  });
}
