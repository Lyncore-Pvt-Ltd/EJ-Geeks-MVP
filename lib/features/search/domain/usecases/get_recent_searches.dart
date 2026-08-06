import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_history_repository.dart';

class GetRecentSearches implements UseCase<List<String>, void> {
  final SearchHistoryRepository _repository;

  GetRecentSearches(this._repository);

  @override
  Future<Either<Failure, List<String>>> call(void params) {
    return _repository.getRecentSearches();
  }
}
