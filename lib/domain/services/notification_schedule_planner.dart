import '../entities/reminder_policy.dart';

class NotificationSchedulePlanner {
  const NotificationSchedulePlanner();

  List<DateTime> scheduledTimes({
    required DateTime dueDate,
    required ReminderPolicy policy,
    required DateTime now,
  }) {
    if (!policy.enabled) return const [];
    final times = <DateTime>[];

    final pre = dueDate.subtract(Duration(days: policy.preDueDays));
    if (!pre.isBefore(now)) times.add(pre);

    var t = dueDate.add(const Duration(days: 1));
    var guard = 0;
    while (!t.isBefore(now) && guard < 10) {
      times.add(t);
      t = t.add(Duration(days: policy.overdueRealertDays));
      guard++;
      if (t.difference(dueDate).inDays > 30) break;
    }
    return times;
  }
}
