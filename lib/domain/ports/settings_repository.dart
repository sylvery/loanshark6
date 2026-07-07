import '../entities/reminder_policy.dart';

abstract class SettingsRepository {
  Future<ReminderPolicy> getReminderPolicy();
  Future<void> setReminderPolicy(ReminderPolicy policy);
}
