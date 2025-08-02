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
  final double aspectRatio; // 1.0 for square, 0.45 for 9:20 (portrait)
  final bool showDaySectionHeader;

  const SettingsState({
    required this.screenshotPath,
    required this.aspectRatio,
    required this.showDaySectionHeader,
  });

  SettingsState copyWith({String? screenshotPath, double? aspectRatio, bool? showDaySectionHeader}) {
    return SettingsState(
      screenshotPath: screenshotPath ?? this.screenshotPath,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      showDaySectionHeader: showDaySectionHeader ?? this.showDaySectionHeader,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _pathKey = 'screenshot_path';
  static const _aspectRatioKey = 'grid_aspect_ratio';
  static const _showDaySectionHeaderKey = 'show_day_section_header';
  // Default path for many Android devices.
  static const _defaultPath = '/storage/emulated/0/DCIM/Screenshots';
  static const _defaultAspectRatio = 1.0; // Square by default
  static const _defaultShowDaySectionHeader = true;

  SettingsNotifier()
      : super(const SettingsState(
          screenshotPath: _defaultPath,
          aspectRatio: _defaultAspectRatio,
          showDaySectionHeader: _defaultShowDaySectionHeader,
        ));

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_pathKey) ?? _defaultPath;
    final aspectRatio = prefs.getDouble(_aspectRatioKey) ?? _defaultAspectRatio;
    final showDaySectionHeader = prefs.getBool(_showDaySectionHeaderKey) ?? _defaultShowDaySectionHeader;
    state = state.copyWith(
      screenshotPath: path,
      aspectRatio: aspectRatio,
      showDaySectionHeader: showDaySectionHeader,
    );
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

  Future<void> setShowDaySectionHeader(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showDaySectionHeaderKey, value);
    state = state.copyWith(showDaySectionHeader: value);
  }
}