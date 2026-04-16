import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Dark theme with Cairo (AR) / Montserrat (EN) and RTL-aware Material 3 colors.
abstract final class AppTheme {
  static ThemeData themeFor(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    final baseDark = ThemeData.dark(useMaterial3: true);
    final textTheme = isArabic
        ? GoogleFonts.cairoTextTheme(baseDark.textTheme)
        : GoogleFonts.montserratTextTheme(baseDark.textTheme);

    final colorScheme = ColorScheme.dark(
      primary: AppColors.accentGold,
      onPrimary: AppColors.primaryEmerald,
      secondary: AppColors.accentGold,
      onSecondary: AppColors.primaryEmerald,
      surface: AppColors.darkBackground,
      onSurface: AppColors.textCream,
      error: Colors.red.shade300,
      onError: AppColors.primaryEmerald,
    );

    return baseDark.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: AppColors.textCream,
        displayColor: AppColors.textCream,
        decorationColor: AppColors.textCream,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryEmerald,
        foregroundColor: AppColors.accentGold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.accentGold,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.primaryEmerald,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.accentGold),
    );
  }
}
