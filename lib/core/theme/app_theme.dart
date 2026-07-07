import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primarySeed = Color(0xFF1FBF75);
  static const Color background = Color(0xFF0E1116);
  static const Color surface = Color(0xFF161B22);
  static const Color danger = Color(0xFFE5534B);
  static const Color warning = Color(0xFFFFB020);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.dark,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardTheme(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: primarySeed.withOpacity(0.2),
        ),
      );
}
