import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Black and gold. Neutral blacks and charcoals with a warm gold accent.
class AppColors {
  static const background = Color(0xFF0B0B0B);
  static const surface = Color(0xFF151515);
  static const surfaceHigh = Color(0xFF1F1D19);

  /// Selected segment / chip fill: a dark, warm gold tint.
  static const goldTint = Color(0xFF2B261B);
  static const gold = Color(0xFFEBD48C);
  static const goldLight = Color(0xFFF6E8B8);
  static const goldDeep = Color(0xFFC9A24D);
  static const textMuted = Color(0xFFA9A59B);
  static const onGold = Color(0xFF17130A);
  static const success = Color(0xFF3FD6A0);

  /// Fine rules and borders: warm, barely there, like a printed hairline.
  static const hairline = Color(0xFF34302A);
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
        outline: const Color(0xFF3A372F),
        outlineVariant: const Color(0xFF2A2822),
      );
  final base = ThemeData(brightness: Brightness.dark).textTheme;
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
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
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
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: AppColors.goldDeep, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.gold),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.goldTint,
      side: const BorderSide(color: Color(0xFF2A2822)),
      labelStyle: const TextStyle(color: Colors.white),
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
          BorderSide(color: Color(0xFF2A2822)),
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
        (s) => s.contains(WidgetState.selected) ? AppColors.gold : Colors.grey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.goldTint
            : const Color(0xFF2A2822),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.35)),
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
        color: Color(0xFFE6E2D8),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHigh,
      elevation: 0,
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      contentTextStyle: const TextStyle(fontSize: 15, color: Colors.white),
      actionTextColor: AppColors.gold,
      showCloseIcon: false,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: Color(0xFF4A463C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        // iOS keeps the native slide and swipe-back gesture.
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF242320)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.goldDeep),
      ),
    ),
  );
}
