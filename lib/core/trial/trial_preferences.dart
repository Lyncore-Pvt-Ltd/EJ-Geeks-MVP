// TEMPORARY TRIAL LOCK — remove when no longer needed
import 'package:shared_preferences/shared_preferences.dart';

class TrialPreferences {
  const TrialPreferences();

  static const _startAtKey = 'trial_start_at';
  static const _unlockedKey = 'trial_unlocked';

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
}
