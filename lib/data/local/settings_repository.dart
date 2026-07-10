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
  static const String _themeKey = 'theme_mode';
  static const String _nameKey = 'display_name';

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

  @override
  Future<String> getThemeMode() async => _prefs.getString(_themeKey) ?? 'dark';

  @override
  Future<void> setThemeMode(String mode) async =>
      _prefs.setString(_themeKey, mode);

  @override
  Future<String?> getDisplayName() async => _prefs.getString(_nameKey);

  @override
  Future<void> setDisplayName(String? name) async {
    if (name == null) {
      await _prefs.remove(_nameKey);
    } else {
      await _prefs.setString(_nameKey, name);
    }
  }
}
