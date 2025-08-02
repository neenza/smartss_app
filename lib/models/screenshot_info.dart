// FILE: lib/models/screenshot_info.dart
import 'dart:io';
import 'dart:typed_data';

class ScreenshotInfo {
  final File file;
  final DateTime timestamp;
  final String packageName;
  final String appName;
  final Uint8List? appIconBytes;

  ScreenshotInfo({
    required this.file,
    required this.timestamp,
    required this.packageName,
    required this.appName,
    required this.appIconBytes,
  });
}