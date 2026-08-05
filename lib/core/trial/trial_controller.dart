// TEMPORARY TRIAL LOCK — remove when no longer needed
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'trial_preferences.dart';

class TrialController extends ChangeNotifier {
  TrialController._(this._preferences, this.startDate, bool unlocked)
    : _unlocked = unlocked;

  // TEMP: shorten (e.g. Duration(seconds: 30)) to test expiry without
  // waiting 2 real days — revert to Duration(days: 2) before shipping
  static const trialDuration = Duration(days: 2);

  static const _unlockCode = 'LYNCORE-2026-UNLOCK';

  static Future<TrialController> create({
    TrialPreferences? preferences,
    PackageInfo? packageInfo,
  }) async {
    final prefs = preferences ?? const TrialPreferences();
    // TEMPORARY TRIAL LOCK — remove when no longer needed
    // A version bump (dev already does this on every release) re-arms a
    // fresh trial window on any device, so shared_preferences surviving an
    // APK update doesn't leave testers stuck on an already-expired trial.
    final info = packageInfo ?? await PackageInfo.fromPlatform();
    final currentVersion = '${info.version}+${info.buildNumber}';
    final lastSeenVersion = await prefs.loadLastSeenVersion();
    if (lastSeenVersion != currentVersion) {
      await prefs.resetTrial();
      await prefs.saveLastSeenVersion(currentVersion);
    }
    final startDate = await prefs.loadOrInitStartDate();
    final unlocked = await prefs.loadUnlocked();
    final expiresAt = startDate.add(trialDuration);
    debugPrint(
      '[TrialController] trial timer started — startDate=$startDate, '
      'expiresAt=$expiresAt, remaining=${expiresAt.difference(DateTime.now())}, '
      'unlocked=$unlocked',
    );
    return TrialController._(prefs, startDate, unlocked);
  }

  final TrialPreferences _preferences;
  final DateTime startDate;
  bool _unlocked;

  bool get isExpired =>
      !_unlocked && DateTime.now().isAfter(startDate.add(trialDuration));

  Future<bool> unlock(String code) async {
    if (code != _unlockCode) return false;
    _unlocked = true;
    await _preferences.saveUnlocked(true);
    notifyListeners();
    return true;
  }
}
