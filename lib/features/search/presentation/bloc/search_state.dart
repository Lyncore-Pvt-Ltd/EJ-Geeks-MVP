import 'package:equatable/equatable.dart';

class SearchState extends Equatable {
  final List<String> recentSearches;
  final bool isLoading;

  const SearchState({this.recentSearches = const [], this.isLoading = false});

  SearchState copyWith({List<String>? recentSearches, bool? isLoading}) {
    return SearchState(
      recentSearches: recentSearches ?? this.recentSearches,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [recentSearches, isLoading];
}
