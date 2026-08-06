import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class SearchHistoryRepository {
  Future<Either<Failure, List<String>>> getRecentSearches();
  Future<Either<Failure, void>> addRecentSearch(String term);
  Future<Either<Failure, void>> clearRecentSearches();
}
