import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

class SearchHistoryLocalDataSource {
  static const _recentSearchesKey = 'invoice_recent_searches';
  static const _maxEntries = 5;

  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      throw CacheException(message: 'Failed to load recent searches: $e');
    }
  }

  Future<void> addRecentSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_recentSearchesKey) ?? [];
      final updated = [
        trimmed,
        ...existing.where(
          (item) => item.toLowerCase() != trimmed.toLowerCase(),
        ),
      ].take(_maxEntries).toList();
      await prefs.setStringList(_recentSearchesKey, updated);
    } catch (e) {
      throw CacheException(message: 'Failed to save recent search: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear recent searches: $e');
    }
  }
}
