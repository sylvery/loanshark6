import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ports/settings_repository.dart';
import '../providers/core_providers.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, String>(
  (ref) => ThemeModeController(ref),
);

class ThemeModeController extends StateNotifier<String> {
  ThemeModeController(this._ref) : super('dark') {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = await _ref.read(settingsRepositoryProvider).getThemeMode();
  }

  Future<void> setMode(String mode) async {
    state = mode;
    await _ref.read(settingsRepositoryProvider).setThemeMode(mode);
  }
}

final displayNameProvider =
    StateNotifierProvider<DisplayNameController, String?>(
  (ref) => DisplayNameController(ref),
);

class DisplayNameController extends StateNotifier<String?> {
  DisplayNameController(this._ref) : super(null) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = await _ref.read(settingsRepositoryProvider).getDisplayName();
  }

  Future<void> set(String? name) async {
    state = name;
    await _ref.read(settingsRepositoryProvider).setDisplayName(name);
  }
}

ThemeMode themeModeFrom(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
