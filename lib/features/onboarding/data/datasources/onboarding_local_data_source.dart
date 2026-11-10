import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

class OnboardingLocalDataSource {
  static const _completedKey = 'onboarding_completed';

  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_completedKey) ?? false;
    } catch (e) {
      throw CacheException(message: 'Failed to read onboarding state: $e');
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_completedKey, true);
    } catch (e) {
      throw CacheException(message: 'Failed to save onboarding state: $e');
    }
  }
}
