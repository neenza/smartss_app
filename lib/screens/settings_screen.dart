// FILE: lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot_manager/services/screenshot_service.dart';
import 'package:screenshot_manager/settings_provider.dart';
import 'package:screenshot_manager/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
    final bool isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(context, 'APPEARANCE'),
          ListTile(
            leading: Icon(isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            title: const Text('Display Mode'),
            trailing: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ThemeType>(
                  value: themeNotifier.themeType,
                  isDense: true,
                  items: [
                    DropdownMenuItem<ThemeType>(
                      value: ThemeType.light,
                      child: const Text('Light'),
                    ),
                    DropdownMenuItem<ThemeType>(
                      value: ThemeType.dark,
                      child: const Text('Dark'),
                    ),
                  ],
                  onChanged: (type) {
                    if (type != null) {
                      ref.read(themeProvider.notifier).setThemeType(type);
                    }
                  },
                ),
              ),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.grid_view_rounded),
            title: const Text('Grid Size'),
            trailing: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: themeNotifier.gridColumns,
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2 Columns')),
                    DropdownMenuItem(value: 3, child: Text('3 Columns')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeProvider.notifier).setGridColumns(value);
                    }
                  },
                ),
              ),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.aspect_ratio),
            title: const Text('Grid Aspect Ratio'),
            trailing: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                  value: settings.aspectRatio,
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: 1.0, child: Text('Square (1:1)')),
                    DropdownMenuItem(value: 0.45, child: Text('Rectangle (9:20)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).setAspectRatio(value);
                    }
                  },
                ),
              ),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.calendar_view_day),
            title: const Text('Show Day Section Header'),
            trailing: Switch(
              value: settings.showDaySectionHeader,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setShowDaySectionHeader(value);
              },
            ),
          ),
          _buildSectionHeader(context, 'STORAGE & CLEANUP'),
          ListTile(
            leading: const Icon(Icons.folder_rounded),
            title: const Text('Screenshot Folder'),
            subtitle: Text(settings.screenshotPath),
            onTap: () => _showEditPathDialog(context, ref),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.storage_rounded),
            title: const Text('Storage Used'),
            subtitle: const Text('Tap to calculate'), // Dynamic calculation is complex
            onTap: () {},
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.security_rounded),
            title: const Text('Request Storage Permission'),
            subtitle: const Text('Tap to enable access'),
            onTap: () async {
              PermissionStatus status;
              if (Theme.of(context).platform == TargetPlatform.android) {
                // Try MANAGE_EXTERNAL_STORAGE for Android 11+
                status = await Permission.manageExternalStorage.request();
              } else {
                status = await Permission.storage.request();
              }
              String message;
              List<Widget> actions = [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ];
              if (status.isGranted) {
                message = 'Storage permission granted!';
              } else if (status.isPermanentlyDenied) {
                message = 'Storage permission permanently denied. Please enable it in app settings.';
                actions.add(
                  TextButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                    child: const Text('Open Settings'),
                  ),
                );
              } else {
                message = 'Storage permission denied.';
              }
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Storage Permission'),
                  content: Text(message),
                  actions: actions,
                ),
              );
            },
          ),
          _buildSectionHeader(context, 'ABOUT'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About App'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showEditPathDialog(BuildContext context, WidgetRef ref) {
    final currentPath = ref.read(settingsProvider).screenshotPath;
    final controller = TextEditingController(text: currentPath);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Screenshot Path'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Folder Path',
              hintText: '/storage/emulated/0/DCIM/Screenshots',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final newPath = controller.text;
                if (newPath.isNotEmpty) {
                  ref.read(settingsProvider.notifier).setScreenshotPath(newPath);
                  final _ = ref.refresh(screenshotProvider); // Refresh data after path change
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

}