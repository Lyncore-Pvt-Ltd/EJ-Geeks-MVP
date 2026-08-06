import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchHistoryRequested extends SearchEvent {
  const SearchHistoryRequested();
}

class SearchTermSubmitted extends SearchEvent {
  final String term;

  const SearchTermSubmitted(this.term);

  @override
  List<Object?> get props => [term];
}

class SearchHistoryCleared extends SearchEvent {
  const SearchHistoryCleared();
}
