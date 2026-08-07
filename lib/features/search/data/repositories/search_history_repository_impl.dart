import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/search_history_repository.dart';
import '../datasources/search_history_local_data_source.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final SearchHistoryLocalDataSource _localDataSource;

  SearchHistoryRepositoryImpl({
    SearchHistoryLocalDataSource? localDataSource,
  }) : _localDataSource = localDataSource ?? SearchHistoryLocalDataSource();

  @override
  Future<Either<Failure, List<String>>> getRecentSearches() async {
    try {
      final searches = await _localDataSource.getRecentSearches();
      return Right(searches);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addRecentSearch(String term) async {
    try {
      await _localDataSource.addRecentSearch(term);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearRecentSearches() async {
    try {
      await _localDataSource.clearRecentSearches();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
