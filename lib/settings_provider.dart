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
  final double aspectRatio; // 1.0 for square, 2.22 for 20:9

  const SettingsState({required this.screenshotPath, required this.aspectRatio});

  SettingsState copyWith({String? screenshotPath, double? aspectRatio}) {
    return SettingsState(
      screenshotPath: screenshotPath ?? this.screenshotPath,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _pathKey = 'screenshot_path';
  static const _aspectRatioKey = 'grid_aspect_ratio';
  // Default path for many Android devices.
  static const _defaultPath = '/storage/emulated/0/DCIM/Screenshots';
  static const _defaultAspectRatio = 1.0; // Square by default

  SettingsNotifier()
      : super(const SettingsState(screenshotPath: _defaultPath, aspectRatio: _defaultAspectRatio));

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_pathKey) ?? _defaultPath;
    final aspectRatio = prefs.getDouble(_aspectRatioKey) ?? _defaultAspectRatio;
    state = state.copyWith(screenshotPath: path, aspectRatio: aspectRatio);
  }

  Future<void> setScreenshotPath(String newPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pathKey, newPath);
    state = state.copyWith(screenshotPath: newPath);
  }

  Future<void> setAspectRatio(double newAspectRatio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_aspectRatioKey, newAspectRatio);
    state = state.copyWith(aspectRatio: newAspectRatio);
  }
}