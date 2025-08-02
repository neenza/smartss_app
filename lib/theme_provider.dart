// FILE: lib/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeType { light, dark }

final themeProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeType _themeType = ThemeType.light;
  ThemeType get themeType => _themeType;

  int _gridColumns = 2;
  int get gridColumns => _gridColumns;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setThemeType(ThemeType type) {
    _themeType = type;
    _themeMode = type == ThemeType.dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setGridColumns(int count) {
    if (count == 2 || count == 3) {
      _gridColumns = count;
      notifyListeners();
    }
  }
}
