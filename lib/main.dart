import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'application/providers/core_providers.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'data/local/local_db.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final db = await LocalDb.open();

  final notificationService = NotificationService(FlutterLocalNotificationsPlugin());
  await notificationService.initialize();

  final auth = AuthListenable();
  final router = buildRouter(auth);

  runApp(
    ProviderScope(
      overrides: [
        localDbProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: MyApp(router: router),
    ),
  );
}
