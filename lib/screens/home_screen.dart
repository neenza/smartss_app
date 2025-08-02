// FILE: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot_manager/services/screenshot_service.dart';
import 'package:screenshot_manager/theme_provider.dart';
import 'package:screenshot_manager/settings_provider.dart';
import 'package:screenshot_manager/widgets/screenshot_grid_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final screenshotsAsync = ref.watch(screenshotProvider);
    final gridColumns = ref.watch(themeProvider).gridColumns;
    final aspectRatio = ref.watch(settingsProvider).aspectRatio;
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
                );
              },
            ),
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