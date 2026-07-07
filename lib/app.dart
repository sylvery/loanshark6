import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BookinMan',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
