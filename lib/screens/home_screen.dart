// FILE: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot_manager/services/screenshot_service.dart';
import 'package:screenshot_manager/theme_provider.dart';
import 'package:screenshot_manager/settings_provider.dart';
import 'package:screenshot_manager/widgets/screenshot_grid_item.dart';
import 'package:screenshot_manager/models/screenshot_info.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  Map<DateTime, List<ScreenshotInfo>> _groupByDay(List<ScreenshotInfo> shots) {
    final Map<DateTime, List<ScreenshotInfo>> grouped = {};
    for (var s in shots) {
      final dateKey = DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day);
      grouped.putIfAbsent(dateKey, () => []).add(s);
    }
    return grouped;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final showYear = dt.year != now.year;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthShort = months[dt.month];
    return showYear ? '$monthShort ${dt.day}, ${dt.year}' : '$monthShort ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final screenshotsAsync = ref.watch(screenshotProvider);
    final gridColumns = ref.watch(themeProvider).gridColumns;
    final aspectRatio = ref.watch(settingsProvider).aspectRatio;
    final showDaySectionHeader = ref.watch(settingsProvider).showDaySectionHeader;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Screenshots'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(screenshotProvider),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by app name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: screenshotsAsync.when(
        data: (screenshots) {
          final filteredScreenshots = _searchQuery.isEmpty
              ? screenshots
              : screenshots.where((s) => s.appName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
          if (filteredScreenshots.isEmpty) {
            return const Center(child: Text('No screenshots found.'));
          }
          if (!showDaySectionHeader) {
            return Scrollbar(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: filteredScreenshots.length,
                itemBuilder: (context, index) {
                  final screenshot = filteredScreenshots[index];
                  return ScreenshotGridItem(
                    imageFile: screenshot.file,
                    timestamp: screenshot.timestamp,
                    appName: screenshot.appName,
                  );
                },
              ),
            );
          }
          // Group by day and show section headers
          // Move grouping and sorting outside the widget tree
          final grouped = _groupByDay(filteredScreenshots);
          final dayKeys = grouped.keys.toList();
          dayKeys.sort((a, b) => b.compareTo(a));

          // Use SliverList for section headers and grids
          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i >= dayKeys.length) return null;
                    final day = dayKeys[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Text(
                            _formatDate(day),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridColumns,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: aspectRatio,
                            ),
                            itemCount: grouped[day]!.length,
                            itemBuilder: (context, idx) {
                              final shot = grouped[day]![idx];
                              return ScreenshotGridItem(
                                imageFile: shot.file,
                                timestamp: shot.timestamp,
                                appName: shot.appName,
                              );
                            },
                          ),
                        ),
                        if (i < dayKeys.length - 1)
                          SizedBox(height: 16), // Add vertical whitespace between day sections
                      ],
                    );
                  },
                  childCount: dayKeys.length,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: ${err.toString()}',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}