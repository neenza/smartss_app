// FILE: lib/services/screenshot_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot_manager/models/screenshot_info.dart';
import 'package:screenshot_manager/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider to fetch screenshots, handling async state and errors.
final screenshotProvider = FutureProvider<List<ScreenshotInfo>>((ref) async {
  final path = ref.watch(settingsProvider).screenshotPath;
  final screenshotService = ref.read(screenshotServiceProvider);
  return screenshotService.getScreenshots(path);
});

final screenshotServiceProvider = Provider((ref) => ScreenshotService());


class AppInfo {
  final String appName;
  final String packageName;
  final String? iconBase64;

  AppInfo({
    required this.appName,
    required this.packageName,
    this.iconBase64,
  });
}

class ScreenshotService {
  static const platform = MethodChannel('app.package/resolve');
  static const _prefsKey = 'appInfoCache';

  final Map<String, AppInfo> _appInfoCache = {};
  bool _cacheLoaded = false;

  Future<void> _loadCache() async {
    if (_cacheLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_prefsKey);
    if (cacheJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(cacheJson);
      decoded.forEach((pkg, info) {
        _appInfoCache[pkg] = AppInfo(
          appName: info['appName'],
          packageName: pkg,
          iconBase64: info['iconBase64'],
        );
      });
    }
    _cacheLoaded = true;
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheMap = _appInfoCache.map((pkg, info) => MapEntry(pkg, {
      'appName': info.appName,
      'iconBase64': info.iconBase64,
    }));
    await prefs.setString(_prefsKey, jsonEncode(cacheMap));
  }

  Future<AppInfo> getAppInfo(String packageName) async {
    await _loadCache();
    if (_appInfoCache.containsKey(packageName)) {
      return _appInfoCache[packageName]!;
    }
    try {
      final result = await platform.invokeMethod('getAppInfo', {'package': packageName});
      final info = AppInfo(
        appName: result['appName'] ?? packageName,
        packageName: packageName,
        iconBase64: result['iconBase64'],
      );
      _appInfoCache[packageName] = info;
      await _saveCache();
      return info;
    } catch (e) {
      final info = AppInfo(appName: packageName, packageName: packageName);
      _appInfoCache[packageName] = info;
      await _saveCache();
      return info;
    }
  }

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

    await _loadCache();

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
            AppInfo appInfo = await getAppInfo(packageName);
            Uint8List? appIconBytes;
            if (appInfo.iconBase64 != null) {
              try {
                appIconBytes = base64Decode(appInfo.iconBase64!);
              } catch (_) {
                appIconBytes = null;
              }
            }
            screenshots.add(
              ScreenshotInfo(
                file: fileEntity,
                timestamp: timestamp,
                packageName: packageName,
                appName: appInfo.appName,
                appIconBytes: appIconBytes,
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