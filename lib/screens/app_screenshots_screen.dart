// FILE: lib/screens/app_screenshots_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot_manager/models/screenshot_info.dart';
import 'package:screenshot_manager/theme_provider.dart';
import 'package:screenshot_manager/settings_provider.dart';
import 'package:screenshot_manager/widgets/screenshot_grid_item.dart';
import 'package:screenshot_manager/screens/screenshot_detail_screen.dart';
class _GroupedScreenshotsGrid extends StatelessWidget {
  final List<ScreenshotInfo> screenshots;
  final int gridColumns;
  final double aspectRatio;
  final bool showDaySectionHeader;

  const _GroupedScreenshotsGrid({
    required this.screenshots,
    required this.gridColumns,
    required this.aspectRatio,
    required this.showDaySectionHeader,
  });

  Map<DateTime, List<ScreenshotInfo>> _groupByDay(List<ScreenshotInfo> shots) {
    final Map<DateTime, List<ScreenshotInfo>> grouped = {};
    for (var s in shots) {
      final dateKey = DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day);
      grouped.putIfAbsent(dateKey, () => []).add(s);
    }
    return grouped;
  }

  String _formatDate(DateTime dt) {
    // Example: Jul 30 or Jul 30, 2024 if not current year
    final now = DateTime.now();
    final showYear = dt.year != now.year;
    final monthShort = _monthShort(dt.month);
    return showYear ? '$monthShort ${dt.day}, ${dt.year}' : '$monthShort ${dt.day}';
  }

  String _monthShort(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    if (!showDaySectionHeader) {
      // Flat grid
      return Scrollbar(
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: aspectRatio,
          ),
          itemCount: screenshots.length,
          itemBuilder: (context, index) {
            return ScreenshotGridItem(
              screenshots: screenshots.map((s) => ScreenshotDetailData(
                imageFile: s.file,
                timestamp: s.timestamp,
                appName: s.appName,
              )).toList(),
              index: index,
            );
          },
        ),
      );
    }
    // Grouped by day
    final grouped = _groupByDay(screenshots);
    final dayKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending by date

    // Build a flat list of ScreenshotDetailData for global indexing
    final allDetailData = screenshots.map((s) => ScreenshotDetailData(
      imageFile: s.file,
      timestamp: s.timestamp,
      appName: s.appName,
    )).toList();

    // Map each screenshot in grouped view to its global index
    int globalIndex = 0;
    return CustomScrollView(
      slivers: [
        for (var i = 0; i < dayKeys.length; i++) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                _formatDate(dayKeys[i]),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: aspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final dayScreenshots = grouped[dayKeys[i]]!;
                  // Find the global index of this screenshot
                  final shot = dayScreenshots[idx];
                  final globalIdx = screenshots.indexOf(shot);
                  return ScreenshotGridItem(
                    screenshots: allDetailData,
                    index: globalIdx,
                  );
                },
                childCount: grouped[dayKeys[i]]!.length,
              ),
            ),
          ),
          if (i < dayKeys.length - 1)
            SliverToBoxAdapter(
              child: SizedBox(height: 16), // Add vertical whitespace between day sections
            ),
        ],
      ],
    );
  }


}


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
    final showDaySectionHeader = ref.watch(settingsProvider).showDaySectionHeader;
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
      ),
      body: _GroupedScreenshotsGrid(
        screenshots: screenshots,
        gridColumns: gridColumns,
        aspectRatio: aspectRatio,
        showDaySectionHeader: showDaySectionHeader,
      ),
    );
  }
}