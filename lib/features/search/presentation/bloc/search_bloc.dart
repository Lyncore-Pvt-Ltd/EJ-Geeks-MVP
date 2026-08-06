import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_recent_search.dart';
import '../../domain/usecases/clear_recent_searches.dart';
import '../../domain/usecases/get_recent_searches.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetRecentSearches _getRecentSearches;
  final AddRecentSearch _addRecentSearch;
  final ClearRecentSearches _clearRecentSearches;

  SearchBloc({
    required GetRecentSearches getRecentSearches,
    required AddRecentSearch addRecentSearch,
    required ClearRecentSearches clearRecentSearches,
  }) : _getRecentSearches = getRecentSearches,
       _addRecentSearch = addRecentSearch,
       _clearRecentSearches = clearRecentSearches,
       super(const SearchState()) {
    on<SearchHistoryRequested>(_onSearchHistoryRequested);
    on<SearchTermSubmitted>(_onSearchTermSubmitted);
    on<SearchHistoryCleared>(_onSearchHistoryCleared);
    add(const SearchHistoryRequested());
  }

  Future<void> _onSearchHistoryRequested(
    SearchHistoryRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _getRecentSearches(null);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false)),
      (searches) =>
          emit(state.copyWith(isLoading: false, recentSearches: searches)),
    );
  }

  Future<void> _onSearchTermSubmitted(
    SearchTermSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    await _addRecentSearch(event.term);
    add(const SearchHistoryRequested());
  }

  Future<void> _onSearchHistoryCleared(
    SearchHistoryCleared event,
    Emitter<SearchState> emit,
  ) async {
    await _clearRecentSearches(null);
    emit(state.copyWith(recentSearches: []));
  }
}
