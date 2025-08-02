// FILE: lib/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, dark }

final themeProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends ChangeNotifier {
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  static const _themeTypeKey = 'theme_type';
  static const _gridColumnsKey = 'grid_columns';

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeType _themeType = ThemeType.light;
  ThemeType get themeType => _themeType;

  int _gridColumns = 2;
  int get gridColumns => _gridColumns;

  ThemeNotifier() {
    _loadThemePrefs();
  }

  Future<void> _loadThemePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final typeStr = prefs.getString(_themeTypeKey);
    if (typeStr != null) {
      _themeType = ThemeType.values.firstWhere(
        (e) => e.toString() == typeStr,
        orElse: () => ThemeType.light,
      );
      _themeMode = _themeType == ThemeType.dark ? ThemeMode.dark : ThemeMode.light;
    }
    final columns = prefs.getInt(_gridColumnsKey);
    if (columns != null && (columns == 2 || columns == 3)) {
      _gridColumns = columns;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _themeType = mode == ThemeMode.dark ? ThemeType.dark : ThemeType.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeTypeKey, _themeType.toString());
    notifyListeners();
  }

  Future<void> setThemeType(ThemeType type) async {
    _themeType = type;
    _themeMode = type == ThemeType.dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeTypeKey, _themeType.toString());
    notifyListeners();
  }

  Future<void> setGridColumns(int count) async {
    if (count == 2 || count == 3) {
      _gridColumns = count;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_gridColumnsKey, count);
      notifyListeners();
    }
  }
}
