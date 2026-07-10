import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const String channelId = 'loan_reminders';
  static const String channelName = 'Loan Reminders';

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> scheduleExact({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _plugin.schedule(
      id,
      title,
      body,
      scheduledDate,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleDailyDigest({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      _details,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);

  Future<void> cancelAll() async => _plugin.cancelAll();

  Future<void> showReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _details);
  }
}
