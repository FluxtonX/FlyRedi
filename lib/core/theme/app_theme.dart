import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    primaryColor: AppColors.primary,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: const Color(0xFF3B82F6),
      surface: Colors.white,
      background: const Color(0xFFF3F4F6),
      onPrimary: Colors.black,
      onSurface: const Color(0xFF1F2937),
      onBackground: const Color(0xFF111827),
      error: const Color(0xFFE11D48),
      outline: const Color(0xFFE5E7EB), // borders
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF111827),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF111827)),
    ),
    dividerColor: const Color(0xFFE5E7EB),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: const Color(0xFF60A5FA),
      surface: AppColors.card,
      background: AppColors.background,
      onPrimary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      error: const Color(0xFFF43F5E),
      outline: const Color(0xFF1A263B), // borders
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    dividerColor: const Color(0xFF1A263B),
  );
}
