import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const String channelId = 'loan_reminders';
  static const String channelName = 'Loan Reminders';

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> showReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  Future<void> notifyOverdue({
    required String customerName,
    required double amount,
    required String currency,
  }) async {
    await showReminder(
      id: customerName.hashCode,
      title: 'Overdue loan',
      body: '$customerName has an overdue payment of $currency '
          '${amount.toStringAsFixed(2)}.',
    );
  }
}
