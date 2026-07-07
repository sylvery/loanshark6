import '../entities/penalty_policy.dart';
import '../entities/reminder_policy.dart';

abstract class SettingsRepository {
  Future<ReminderPolicy> getReminderPolicy();
  Future<void> setReminderPolicy(ReminderPolicy policy);
  Future<PenaltyPolicy> getPenaltyPolicy();
  Future<void> setPenaltyPolicy(PenaltyPolicy policy);
}
