import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/reminder_policy.dart';
import '../../domain/ports/settings_repository.dart';

class SharedPreferencesSettings implements SettingsRepository {
  SharedPreferencesSettings(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'reminder_policy';

  @override
  Future<ReminderPolicy> getReminderPolicy() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return const ReminderPolicy();
    return ReminderPolicy.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  Future<void> setReminderPolicy(ReminderPolicy policy) async {
    await _prefs.setString(_key, jsonEncode(policy.toJson()));
  }
}
