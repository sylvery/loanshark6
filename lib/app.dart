import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'application/notifications/notification_providers.dart';
import 'application/settings/settings_providers.dart';
import 'application/sync/sync_providers.dart';
import 'core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncAutoRetryProvider);
    ref.watch(notificationAutoScheduleProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'BookinMan',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModeFrom(themeMode),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
