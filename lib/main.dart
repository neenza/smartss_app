import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot_manager/settings_provider.dart';
import 'package:screenshot_manager/theme_provider.dart';
import 'package:screenshot_manager/home_scaffold.dart';

void main() async {
  // Ensure that widget binding is initialized for async operations before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create a provider container to initialize settings before the app starts.
  final container = ProviderContainer();
  await container.read(settingsProvider.notifier).loadSettings();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Screenshot Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).primaryTextTheme,
        ),
        useMaterial3: true,
      ),
      themeMode: themeNotifier.themeMode,
      home: const HomeScaffold(),
    );
  }
}