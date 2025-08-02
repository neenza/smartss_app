// FILE: lib/models/screenshot_info.dart
import 'dart:io';

class ScreenshotInfo {
  final File file;
  final DateTime timestamp;
  final String packageName;
  final String appName;
  final dynamic appIcon; // Can be IconData or an asset path string

  ScreenshotInfo({
    required this.file,
    required this.timestamp,
    required this.packageName,
    required this.appName,
    required this.appIcon,
  });
}