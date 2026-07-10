import 'package:bookinman/domain/entities/reminder_policy.dart';
import 'package:bookinman/domain/services/notification_schedule_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationSchedulePlanner', () {
    final planner = const NotificationSchedulePlanner();
    final now = DateTime(2024, 6, 15);

    test('returns empty when disabled', () {
      final policy = const ReminderPolicy(enabled: false);
      expect(
        planner.scheduledTimes(
          dueDate: DateTime(2024, 6, 20),
          policy: policy,
          now: now,
        ),
        isEmpty,
      );
    });

    test('includes pre-due reminder before the due date', () {
      final policy = const ReminderPolicy(preDueDays: 2);
      final times = planner.scheduledTimes(
        dueDate: DateTime(2024, 6, 20),
        policy: policy,
        now: now,
      );
      expect(times, contains(DateTime(2024, 6, 18)));
    });

    test('includes overdue re-alerts after the due date', () {
      final policy = const ReminderPolicy(preDueDays: 0, overdueRealertDays: 3);
      final times = planner.scheduledTimes(
        dueDate: DateTime(2024, 6, 10),
        policy: policy,
        now: now,
      );
      expect(times, isNotEmpty);
      expect(times.first, DateTime(2024, 6, 11));
    });

    test('does not schedule times already in the past', () {
      final policy = const ReminderPolicy(preDueDays: 10);
      final times = planner.scheduledTimes(
        dueDate: DateTime(2024, 6, 20),
        policy: policy,
        now: now,
      );
      for (final t in times) {
        expect(t.isBefore(now), isFalse);
      }
    });
  });
}
