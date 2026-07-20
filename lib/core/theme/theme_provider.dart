import 'package:flutter/material.dart';
import '../storage/storage_service.dart';
import '../logging/app_logger.dart';

/// Replaces the old GetX [ThemeController].
/// Persists the user's theme preference via [StorageService].
class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;

  static const String _themeKey = 'isDarkMode';

  bool _isDarkMode;

  ThemeProvider(this._storage) : _isDarkMode = _loadInitialTheme(_storage);

  static bool _loadInitialTheme(StorageService storage) {
    final stored = storage.getCache(_themeKey);
    return stored is bool ? stored : true; // Default: dark mode
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.saveCache(_themeKey, _isDarkMode);
    AppLogger.provider('ThemeProvider', _isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await _storage.saveCache(_themeKey, _isDarkMode);
    AppLogger.provider('ThemeProvider', _isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }
}
