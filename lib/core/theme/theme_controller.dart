import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';

class ThemeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final _isDarkMode = true.obs;

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final storedMode = _storage.getCache('isDarkMode');
    if (storedMode != null) {
      _isDarkMode.value = storedMode as bool;
    } else {
      _isDarkMode.value = true; // Default to dark mode matching original app
    }
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _storage.saveCache('isDarkMode', _isDarkMode.value);
    
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get themeMode => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
