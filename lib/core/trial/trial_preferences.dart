// TEMPORARY TRIAL LOCK — remove when no longer needed
import 'package:shared_preferences/shared_preferences.dart';

class TrialPreferences {
  const TrialPreferences();

  static const _startAtKey = 'trial_start_at';
  static const _unlockedKey = 'trial_unlocked';
  static const _lastSeenVersionKey = 'trial_last_seen_version';

  Future<DateTime> loadOrInitStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_startAtKey);
    if (stored != null) {
      return DateTime.parse(stored);
    }
    final now = DateTime.now();
    await prefs.setString(_startAtKey, now.toIso8601String());
    return now;
  }

  Future<bool> loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unlockedKey) ?? false;
  }

  Future<void> saveUnlocked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unlockedKey, value);
  }

  Future<String?> loadLastSeenVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSeenVersionKey);
  }

  Future<void> saveLastSeenVersion(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenVersionKey, value);
  }

  Future<void> resetTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startAtKey, DateTime.now().toIso8601String());
    await prefs.setBool(_unlockedKey, false);
  }
}
