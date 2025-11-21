/// App Theme
/// Gradient-free modern design system
/// Flat surfaces, clear typography, generous spacing
library;

import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================================
  // COLORS - PREMIUM MATTE & STEALTH (No Gradients)
  // ============================================================================

  // Palette
  static const Color _midnightBlue = Color(0xFF0F172A); // Deep background
  static const Color _charcoal = Color(0xFF1E293B); // Surface
  static const Color _slate = Color(0xFF334155); // Lighter surface/border
  static const Color _electricBlue = Color(0xFF00F0FF); // Primary Accent (Cyan)
  static const Color _neonMint = Color(0xFF00FF9D); // Secondary Accent
  static const Color _errorRed = Color(0xFFFF453A);

  // Text Colors
  static const Color _textPrimary = Color(0xFFF8FAFC); // White-ish
  static const Color _textSecondary = Color(0xFF94A3B8); // Muted slate

  // Semantic Colors
  static const Color success = _neonMint;
  static const Color warning = Color(0xFFFF453A); // Amber/Orange
  static const Color info = _electricBlue;

  // ============================================================================
  // SPACING (8dp grid)
  // ============================================================================

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0; // Increased for modern feel
  static const double radiusPill = 999.0;

  // ============================================================================
  // DARK THEME (Primary)
  // ============================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',

      colorScheme: const ColorScheme.dark(
        primary: _electricBlue,
        secondary: _neonMint,
        surface: _charcoal,
        error: _errorRed,
        onPrimary: _midnightBlue, // Black text on electric blue
        onSecondary: _midnightBlue,
        onSurface: _textPrimary,
        onError: _textPrimary,
      ),

      scaffoldBackgroundColor: _midnightBlue,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: _midnightBlue, // Matte background
        foregroundColor: _textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5, // Technical feel
          color: _textPrimary,
        ),
        iconTheme: IconThemeData(color: _textPrimary),
      ),

      // Card - Matte Surface with subtle border
      cardTheme: CardThemeData(
        color: _charcoal,
        elevation: 4, // Subtle shadow for depth
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(
            color: Colors.white10,
            width: 1,
          ), // Subtle border
        ),
        margin: const EdgeInsets.only(bottom: spacing16),
      ),

      // Input decoration - Filled, glowing border on focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _charcoal,
        hintStyle: const TextStyle(color: _textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _slate, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: _electricBlue,
            width: 1.5,
          ), // Glowing effect
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _errorRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing20,
          vertical: spacing16,
        ),
      ),

      // Elevated button - Pill shape, tactile
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _electricBlue,
          foregroundColor: _midnightBlue, // Contrast text
          elevation: 4,
          shadowColor: _electricBlue.withOpacity(0.4), // Colored shadow/glow
          padding: const EdgeInsets.symmetric(
            horizontal: spacing32,
            vertical: spacing16,
          ),
          shape: const StadiumBorder(), // Pill shape
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _electricBlue,
          side: const BorderSide(color: _electricBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing32,
            vertical: spacing16,
          ),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _electricBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing12,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Icon button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: _textPrimary),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _electricBlue,
        foregroundColor: _midnightBlue,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _midnightBlue,
        selectedItemColor: _electricBlue,
        unselectedItemColor: _textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _slate,
        thickness: 1,
        space: 1,
      ),

      // Typography
      textTheme: _buildTextTheme(_textPrimary),
    );
  }

  // ============================================================================
  // LIGHT THEME (Adapted for consistency, but Dark is primary)
  // ============================================================================

  static ThemeData get lightTheme {
    // For a "Stealth" app, even light mode should feel technical and clean.
    // Using high contrast dark text on off-white backgrounds.
    const Color lightBg = Color(0xFFF1F5F9);
    const Color lightSurface = Color(0xFFFFFFFF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: _electricBlue, // Keep identity
        secondary: _neonMint,
        surface: lightSurface,
        error: _errorRed,
        onPrimary: _midnightBlue,
        onSecondary: _midnightBlue,
        onSurface: _midnightBlue,
      ),

      scaffoldBackgroundColor: lightBg,

      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: _midnightBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: _midnightBlue,
        ),
      ),

      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        margin: const EdgeInsets.only(bottom: spacing16),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: const TextStyle(color: _textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Color(0xFFCBD5E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _electricBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing20,
          vertical: spacing16,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _midnightBlue, // Dark button on light mode for contrast
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing32,
            vertical: spacing16,
          ),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textTheme: _buildTextTheme(_midnightBlue),
    );
  }

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.25,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),

      // Headline - Technical feel
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5, // Increased spacing
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: baseColor,
      ),

      // Title
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: baseColor,
      ),

      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: baseColor.withOpacity(0.7),
      ),

      // Label
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0, // Uppercase buttons usually
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: baseColor,
      ),
    );
  }
}
