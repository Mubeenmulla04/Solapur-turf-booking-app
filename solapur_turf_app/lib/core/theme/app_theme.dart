import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Premium SaaS App Theme Configuration (Light & Dark Support)
/// Incorporates rounded edges, soft off-white/slate backgrounds, no harsh shadows, 
/// and deeply saturated primary buttons.
class AppTheme {
  AppTheme._();

  // ── LIGHT THEME (Soft Neumorphic Feel) ────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Change to 'Inter' if imported
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceLight,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,

        // AppBar (Glassmorphic / Clean Surface)
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark, // Dark status bar icons
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2, // Tighter tracking for headers
            color: AppColors.textPrimaryLight,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        ),

        // Primary Button (Pulsing, soft-rounded, deeply saturated CTA)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: const Size(double.infinity, 56), // Larger thumb area
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Softer radius
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            elevation: 4, // Soft primary elevation
            shadowColor: AppColors.primary.withOpacity(0.4), // Tinted shadow mimicking neon glow
          ),
        ),

        // Secondary Buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimaryLight, // Not primary colored commonly
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: AppColors.dividerLight, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.surfaceLight,
          ),
        ),

        // Ghost Buttons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Text Fields (Minimal box, no aggressive stroke until focused)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantLight, // Soft grey background
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Invisible border by default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          hintStyle: const TextStyle(
            color: AppColors.textSecondaryLight,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Cards (The Floating Slate System)
        cardTheme: CardThemeData(
          color: AppColors.surfaceLight,
          elevation: 0,
          shadowColor: Colors.transparent, // Disable native drop shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 20px radius cards via Zomato
            side: const BorderSide(color: AppColors.dividerLight, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),

        // Scaffold / Bottom Navigation 
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryLight,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        // Chips (Pill filters for Sports, Time)
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariantLight,
          selectedColor: AppColors.primaryContainer,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryLight),
          secondaryLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none, // No border for inactive
          ),
          elevation: 0,
          pressElevation: 0,
        ),

        // Dividers
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerLight,
          thickness: 1,
          space: 1,
        ),
      );


  // ── DARK THEME (Cinema Midnight Feel) ──────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryLight, // Brighter seed for dark mode
          brightness: Brightness.dark,
          primary: AppColors.primaryLight,
          onPrimary: AppColors.textPrimaryLight, // Dark text on light-green primary buttons
          secondary: AppColors.secondary,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark, // Elevated above absolute darkness
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColors.textPrimaryDark,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.textPrimaryLight, // Dark text against neon green
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 8,
            shadowColor: AppColors.primaryLight.withOpacity(0.3),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimaryDark,
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: AppColors.dividerDark, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: AppColors.surfaceDark,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantDark,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          hintStyle: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),

        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.dividerDark, width: 1), // Thicker border for dark contrast
          ),
          margin: EdgeInsets.zero,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textSecondaryDark,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariantDark,
          selectedColor: AppColors.primaryDark,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
          secondaryLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryLight),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
          elevation: 0,
          pressElevation: 0,
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 1,
        ),
      );
}
