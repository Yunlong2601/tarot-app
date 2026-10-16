import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0E0B1A);
  static const surface = Color(0xFF1A1530);
  static const surfaceHigh = Color(0xFF241D42);
  static const gold = Color(0xFFD9B26F);
  static const violet = Color(0xFF8B7BFF);
  static const textMuted = Color(0xFFB4AECB);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.violet,
    brightness: Brightness.dark,
  ).copyWith(
    surface: AppColors.surface,
    primary: AppColors.gold,
    onPrimary: const Color(0xFF1B1408),
    secondary: AppColors.violet,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
    ),
  );
}
