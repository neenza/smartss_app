// FILE: lib/screens/app_screenshots_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot_manager/models/screenshot_info.dart';
import 'package:screenshot_manager/theme_provider.dart';
import 'package:screenshot_manager/settings_provider.dart';
import 'package:screenshot_manager/widgets/screenshot_grid_item.dart';

class AppScreenshotsScreen extends ConsumerWidget {
  final String appName;
  final List<ScreenshotInfo> screenshots;

  const AppScreenshotsScreen({
    super.key,
    required this.appName,
    required this.screenshots,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridColumns = ref.watch(themeProvider).gridColumns;
    final aspectRatio = ref.watch(settingsProvider).aspectRatio;

    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: aspectRatio,
        ),
        itemCount: screenshots.length,
        itemBuilder: (context, index) {
          final screenshot = screenshots[index];
          return ScreenshotGridItem(
            imageFile: screenshot.file,
            timestamp: screenshot.timestamp,
          );
        },
      ),
    );
  }
}