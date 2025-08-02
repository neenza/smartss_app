// FILE: lib/screens/apps_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot_manager/models/screenshot_info.dart';
import 'package:screenshot_manager/screens/app_screenshots_screen.dart';
import 'package:screenshot_manager/services/screenshot_service.dart';

class AppsScreen extends ConsumerStatefulWidget {
  const AppsScreen({super.key});

  @override
  ConsumerState<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends ConsumerState<AppsScreen> {
  String _searchQuery = '';

  Map<String, List<ScreenshotInfo>> _groupScreenshotsByApp(List<ScreenshotInfo> screenshots) {
    final Map<String, List<ScreenshotInfo>> grouped = {};
    for (var s in screenshots) {
      if (!grouped.containsKey(s.packageName)) {
        grouped[s.packageName] = [];
      }
      grouped[s.packageName]!.add(s);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final screenshotsAsync = ref.watch(screenshotProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screenshots by App'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search apps...',
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
        data: (allScreenshots) {
          final groupedByApp = _groupScreenshotsByApp(allScreenshots);
          final appKeys = groupedByApp.keys.toList();
          final filteredAppKeys = _searchQuery.isEmpty
              ? appKeys
              : appKeys.where((key) {
                  final appName = groupedByApp[key]!.first.appName;
                  return appName.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

          if (filteredAppKeys.isEmpty) {
            return const Center(child: Text('No apps found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredAppKeys.length,
            itemBuilder: (context, index) {
              final packageName = filteredAppKeys[index];
              final screenshots = groupedByApp[packageName]!;
              final firstScreenshot = screenshots.first;
              final count = screenshots.length;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: firstScreenshot.appIconBytes != null
                      ? Image.memory(
                          firstScreenshot.appIconBytes!,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.apps_rounded,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                  ),
                  title: Text(firstScreenshot.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$count screenshot${count > 1 ? 's' : ''}'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppScreenshotsScreen(
                          appName: firstScreenshot.appName,
                          screenshots: screenshots,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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