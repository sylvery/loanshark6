import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/penalty_policy.dart';
import '../../domain/entities/reminder_policy.dart';
import '../../domain/ports/settings_repository.dart';

class SharedPreferencesSettings implements SettingsRepository {
  SharedPreferencesSettings(this._prefs);

  final SharedPreferences _prefs;
  static const String _reminderKey = 'reminder_policy';
  static const String _penaltyKey = 'penalty_policy';

  @override
  Future<ReminderPolicy> getReminderPolicy() async {
    final raw = _prefs.getString(_reminderKey);
    if (raw == null) return const ReminderPolicy();
    return ReminderPolicy.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  Future<void> setReminderPolicy(ReminderPolicy policy) async {
    await _prefs.setString(_reminderKey, jsonEncode(policy.toJson()));
  }

  @override
  Future<PenaltyPolicy> getPenaltyPolicy() async {
    final raw = _prefs.getString(_penaltyKey);
    if (raw == null) return const PenaltyPolicy();
    return PenaltyPolicy.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  Future<void> setPenaltyPolicy(PenaltyPolicy policy) async {
    await _prefs.setString(_penaltyKey, jsonEncode(policy.toJson()));
  }
}
