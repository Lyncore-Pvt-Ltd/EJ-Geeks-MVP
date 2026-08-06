import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_history_repository.dart';

class ClearRecentSearches implements UseCase<void, void> {
  final SearchHistoryRepository _repository;

  ClearRecentSearches(this._repository);

  @override
  Future<Either<Failure, void>> call(void params) {
    return _repository.clearRecentSearches();
  }
}
