import '../entities/penalty_policy.dart';
import '../entities/reminder_policy.dart';

abstract class SettingsRepository {
  Future<ReminderPolicy> getReminderPolicy();
  Future<void> setReminderPolicy(ReminderPolicy policy);
  Future<PenaltyPolicy> getPenaltyPolicy();
  Future<void> setPenaltyPolicy(PenaltyPolicy policy);

  /// Theme mode preference: 'system', 'light' or 'dark'.
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);

  /// User's chosen display name (null when not set).
  Future<String?> getDisplayName();
  Future<void> setDisplayName(String? name);
}
