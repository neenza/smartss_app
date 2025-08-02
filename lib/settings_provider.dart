// FILE: lib/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This provider manages user-configurable settings that need to be persisted.
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

@immutable
class SettingsState {
  final String screenshotPath;

  const SettingsState({required this.screenshotPath});

  SettingsState copyWith({String? screenshotPath}) {
    return SettingsState(
      screenshotPath: screenshotPath ?? this.screenshotPath,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _pathKey = 'screenshot_path';
  // Default path for many Android devices.
  static const _defaultPath = '/storage/emulated/0/DCIM/Screenshots';

  SettingsNotifier() : super(const SettingsState(screenshotPath: _defaultPath));

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_pathKey) ?? _defaultPath;
    state = state.copyWith(screenshotPath: path);
  }

  Future<void> setScreenshotPath(String newPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pathKey, newPath);
    state = state.copyWith(screenshotPath: newPath);
  }
}