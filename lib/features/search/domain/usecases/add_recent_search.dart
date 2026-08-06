import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_history_repository.dart';

class AddRecentSearch implements UseCase<void, String> {
  final SearchHistoryRepository _repository;

  AddRecentSearch(this._repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repository.addRecentSearch(params);
  }
}
