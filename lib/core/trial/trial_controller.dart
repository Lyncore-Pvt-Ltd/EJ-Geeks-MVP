// TEMPORARY TRIAL LOCK — remove when no longer needed
import 'package:flutter/material.dart';

import 'trial_preferences.dart';

class TrialController extends ChangeNotifier {
  TrialController._(this._preferences, this.startDate, bool unlocked)
    : _unlocked = unlocked;

  // TEMP: shorten (e.g. Duration(seconds: 30)) to test expiry without
  // waiting 2 real days — revert to Duration(days: 2) before shipping
  static const trialDuration = Duration(days: 2);

  static const _unlockCode = 'LYNCORE-2026-UNLOCK';

  static Future<TrialController> create({TrialPreferences? preferences}) async {
    final prefs = preferences ?? const TrialPreferences();
    final startDate = await prefs.loadOrInitStartDate();
    final unlocked = await prefs.loadUnlocked();
    // TEMPORARY TRIAL LOCK — remove when no longer needed
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
