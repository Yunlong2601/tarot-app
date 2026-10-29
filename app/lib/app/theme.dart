import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Candlelit table: warm blacks, paper-white ink and one earthy gold accent.
/// The card art is the brightest thing on screen. See docs/DESIGN.md.
class AppColors {
  static const background = Color(0xFF0A0908);
  static const surface = Color(0xFF141210);
  static const surfaceHigh = Color(0xFF1E1A16);

  /// Selected segment / chip fill: a dark, warm gold tint.
  static const goldTint = Color(0xFF29221A);
  static const gold = Color(0xFFD9B46A);
  static const goldLight = Color(0xFFEBD9A8);
  static const goldDeep = Color(0xFF9C7A3C);

  /// Primary text: warm paper white, never pure white.
  static const ink = Color(0xFFF3EEE4);
  static const textMuted = Color(0xFFA39C8F);
  static const onGold = Color(0xFF17120A);
  static const success = Color(0xFF8FA08A);
  static const error = Color(0xFFD0644A);

  /// Fine rules and borders: warm, barely there, like a printed hairline.
  static const hairline = Color(0xFF2E2922);
}

/// Corner radii, one per role.
class AppRadius {
  static const card = 10.0;
  static const control = 8.0;
  static const tarot = 6.0;
}

/// Editorial display face for titles and card names. Baskerville and Georgia
/// ship with iOS, so nothing is downloaded; Android falls back to its serif.
const displayFont = 'Baskerville';
const displayFallback = ['Georgia', 'Noto Serif', 'serif'];

TextStyle _display(double size, {FontWeight weight = FontWeight.w500}) =>
    TextStyle(
      fontFamily: displayFont,
      fontFamilyFallback: displayFallback,
      fontSize: size,
      fontWeight: weight,
      height: 1.15,
      letterSpacing: 0.2,
    );

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.surface,
        primary: AppColors.gold,
        onPrimary: AppColors.onGold,
        secondary: AppColors.goldDeep,
        primaryContainer: AppColors.goldTint,
        onPrimaryContainer: AppColors.gold,
        onSurface: AppColors.ink,
        error: AppColors.error,
        outline: AppColors.hairline,
        outlineVariant: AppColors.hairline,
      );
  final base = ThemeData(brightness: Brightness.dark).textTheme
      .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: base.copyWith(
      displayLarge: base.displayLarge?.merge(_display(52)),
      displayMedium: base.displayMedium?.merge(_display(44)),
      displaySmall: base.displaySmall?.merge(_display(36)),
      headlineLarge: base.headlineLarge?.merge(_display(32)),
      headlineMedium: base.headlineMedium?.merge(_display(28)),
      headlineSmall: base.headlineSmall?.merge(_display(24)),
      titleLarge: base.titleLarge?.merge(_display(22)),
      // Reading text: iOS tracking (slightly negative at body sizes) and
      // generous line height. Material's positive tracking reads as spaced
      // out in long passages.
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 17,
        height: 1.5,
        letterSpacing: -0.2,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15.5,
        height: 1.45,
        letterSpacing: -0.15,
      ),
      bodySmall: base.bodySmall?.copyWith(letterSpacing: 0),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      labelLarge: base.labelLarge?.copyWith(letterSpacing: -0.1),
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: displayFallback,
        fontSize: 21,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.hairline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.onGold,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.goldDeep, width: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.gold),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.goldTint,
      side: const BorderSide(color: AppColors.hairline),
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(color: AppColors.ink),
      secondaryLabelStyle: const TextStyle(color: AppColors.gold),
      checkmarkColor: AppColors.gold,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.goldTint
              : AppColors.surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.gold
              : AppColors.textMuted,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.hairline),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.background,
      indicatorColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? AppColors.gold
              : AppColors.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: s.contains(WidgetState.selected)
              ? AppColors.gold
              : AppColors.textMuted,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.gold
            : AppColors.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.goldTint
            : AppColors.hairline,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.hairline),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: displayFallback,
        fontSize: 23,
        fontWeight: FontWeight.w500,
        color: AppColors.goldLight,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        height: 1.4,
        color: AppColors.ink,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHigh,
      elevation: 0,
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.hairline),
      ),
      contentTextStyle: const TextStyle(fontSize: 15, color: AppColors.ink),
      actionTextColor: AppColors.gold,
      showCloseIcon: false,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: Color(0xFF4A463C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        // iOS keeps the native slide and swipe-back gesture.
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    dividerTheme: const DividerThemeData(color: AppColors.hairline),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.goldDeep),
      ),
    ),
  );
}
