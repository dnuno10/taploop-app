import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display — Outfit
      displayLarge: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        height: 1.15,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        height: 1.2,
      ),
      // Headline — Outfit
      headlineLarge: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.3,
      ),
      // Title — Outfit
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.4,
      ),
      // Body — DM Sans
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
        height: 1.5,
      ),
      // Label — DM Sans
      labelLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
        height: 1.3,
      ),
    );
  }

  static ThemeData get light {
    final textTheme = _buildTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.black,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.black,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.white,
      cardColor: const Color(0xFFFCFAF8),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.black),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFCFAF8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.grey),
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.lightGrey),
        errorStyle: GoogleFonts.dmSans(fontSize: 12, color: AppColors.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              mouseCursor: const WidgetStatePropertyAll(
                SystemMouseCursors.click,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: AppColors.black,
              side: const BorderSide(color: AppColors.border, width: 1.5),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              mouseCursor: const WidgetStatePropertyAll(
                SystemMouseCursors.click,
              ),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              mouseCursor: const WidgetStatePropertyAll(
                SystemMouseCursors.click,
              ),
            ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      radioTheme: RadioThemeData(
        mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      switchTheme: SwitchThemeData(
        mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  static ThemeData get dark {
    const bg = Color(0xFF0F172A);
    const card = Color(0xFF1E293B);
    const border = Color(0xFF334155);
    const textPrimary = Color(0xFFF1F5F9);
    const textSecondary = Color(0xFF94A3B8);

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.15,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: const Color(0xFF94A3B8),
        onSecondary: Colors.white,
        surface: card,
        onSurface: textPrimary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(fontSize: 14, color: textSecondary),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: const Color(0xFF64748B),
        ),
        errorStyle: GoogleFonts.dmSans(fontSize: 12, color: AppColors.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              mouseCursor: const WidgetStatePropertyAll(
                SystemMouseCursors.click,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: textPrimary,
              side: const BorderSide(color: border, width: 1.5),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              mouseCursor: const WidgetStatePropertyAll(
                SystemMouseCursors.click,
              ),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              mouseCursor: const WidgetStatePropertyAll(
                SystemMouseCursors.click,
              ),
            ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      radioTheme: RadioThemeData(
        mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      switchTheme: SwitchThemeData(
        mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: GoogleFonts.dmSans(fontSize: 14, color: textPrimary),
      ),
    );
  }
}
