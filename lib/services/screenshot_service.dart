// FILE: lib/services/screenshot_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot_manager/models/screenshot_info.dart';
import 'package:screenshot_manager/settings_provider.dart';
import 'package:device_apps/device_apps.dart';

// Provider to fetch screenshots, handling async state and errors.
final screenshotProvider = FutureProvider<List<ScreenshotInfo>>((ref) async {
  final path = ref.watch(settingsProvider).screenshotPath;
  final screenshotService = ref.read(screenshotServiceProvider);
  return screenshotService.getScreenshots(path);
});

final screenshotServiceProvider = Provider((ref) => ScreenshotService());


class ScreenshotService {
  // Fallback icons for unknown apps
  static const IconData _defaultIcon = Icons.apps_rounded;

  Future<bool> _requestPermission() async {
    // ...existing code...
    if (Platform.isAndroid) {
      int sdkInt = 0;
      try {
        sdkInt = int.parse((await File('/system/build.prop').readAsLines()).firstWhere((line) => line.startsWith('ro.build.version.sdk')).split('=')[1]);
      } catch (_) {
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

    // Fetch all installed apps once and build a lookup map
    Map<String, dynamic> installedAppsMap = {};
    try {
      final installedApps = await DeviceApps.getInstalledApplications(includeAppIcons: false, includeSystemApps: true);
      for (var app in installedApps) {
        installedAppsMap[app.packageName] = app;
      }
    } catch (e) {
      // If fetching installed apps fails, fallback to empty map
      installedAppsMap = {};
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
            String appName = packageName; // fallback to package name
            IconData appIcon = _defaultIcon;
            if (installedAppsMap.containsKey(packageName)) {
              final app = installedAppsMap[packageName];
              appName = app.appName ?? packageName;
              // device_apps only provides icon as bytes, not IconData
              // You may want to display Image.memory(app.icon) elsewhere
            } else {
              appName = packageName; // fallback to package name
            }
            screenshots.add(
              ScreenshotInfo(
                file: fileEntity,
                timestamp: timestamp,
                packageName: packageName,
                appName: appName,
                appIcon: appIcon,
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