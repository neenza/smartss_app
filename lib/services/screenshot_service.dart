// FILE: lib/services/screenshot_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot_manager/models/screenshot_info.dart';
import 'package:screenshot_manager/settings_provider.dart';

// Provider to fetch screenshots, handling async state and errors.
final screenshotProvider = FutureProvider<List<ScreenshotInfo>>((ref) async {
  final path = ref.watch(settingsProvider).screenshotPath;
  final screenshotService = ref.read(screenshotServiceProvider);
  return screenshotService.getScreenshots(path);
});

final screenshotServiceProvider = Provider((ref) => ScreenshotService());

class ScreenshotService {
  static const Map<String, Map<String, dynamic>> _appInfoMap = {
    'com.reddit.frontpage': {'name': 'Reddit', 'icon': Icons.reddit_rounded},
    'com.twitter.android': {'name': 'Twitter / X', 'icon': Icons.close_rounded},
    'com.instagram.android': {'name': 'Instagram', 'icon': Icons.camera_alt_rounded},
    'com.google.android.gm': {'name': 'Gmail', 'icon': Icons.mail_rounded},
    'com.whatsapp': {'name': 'WhatsApp', 'icon': Icons.chat_bubble_rounded},
    'com.android.chrome': {'name': 'Chrome', 'icon': Icons.chrome_reader_mode_rounded},
  };
  
  Future<bool> _requestPermission() async {
    // Check Android version
    if (Platform.isAndroid) {
      int sdkInt = 0;
      try {
        sdkInt = int.parse((await File('/system/build.prop').readAsLines()).firstWhere((line) => line.startsWith('ro.build.version.sdk')).split('=')[1]);
      } catch (_) {
        // Fallback: assume 30+
        sdkInt = 30;
      }
      if (sdkInt >= 30) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
        if (!status.isGranted && status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return status.isGranted;
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    } else {
      // Non-Android platforms
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
  }

  Future<List<ScreenshotInfo>> getScreenshots(String path) async {
    if (!await _requestPermission()) {
      throw Exception('Storage permission was denied.');
    }
    
    final directory = Directory(path);
    if (!await directory.exists()) {
      throw Exception('Directory not found: $path. Please check the path in Settings.');
    }

    final List<ScreenshotInfo> screenshots = [];
    final regex = RegExp(r'Screenshot_(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{3})_(.*)\.(jpg|png)');

    final files = await directory.list().toList();

    for (var fileEntity in files) {
      if (fileEntity is File) {
        final fileName = fileEntity.path.split('/').last;
        final match = regex.firstMatch(fileName);

        if (match != null) {
          final timestampStr = match.group(1);
          final packageName = match.group(2) ?? 'unknown';

          try {
            final timestamp = DateFormat('yyyy-MM-dd-HH-mm-ss-SSS').parse(timestampStr!);
            final appInfo = _appInfoMap[packageName] ?? {'name': 'Unknown App', 'icon': Icons.apps_rounded};
            
            screenshots.add(
              ScreenshotInfo(
                file: fileEntity,
                timestamp: timestamp,
                packageName: packageName,
                appName: appInfo['name'],
                appIcon: appInfo['icon'],
              ),
            );
          } catch (e) {
            // Ignore files with invalid timestamp format
          }
        }
      }
    }
    
    screenshots.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return screenshots;
  }
}