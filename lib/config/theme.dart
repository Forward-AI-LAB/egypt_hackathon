/// ====================================================================
/// Forward AI — App Theme Configuration
/// ====================================================================
/// Centralized theme definition following Material Design 3 guidelines.
///
/// Design Pattern: Theme Configuration Object
///   - All colors, typography, and component styles defined in one place.
///   - Easy to create light/dark variants or brand-specific themes.
///   - Consistent look across the entire app.
///
/// Color Palette:
///   - Primary: Deep Indigo (#4F46E5) — trust, intelligence
///   - Secondary: Cyan/Teal (#06B6D4) — tech, innovation
///   - Accent: Amber (#F59E0B) — highlights, achievements
///   - Background: Dark charcoal (#0F172A) — modern, premium feel
/// ====================================================================
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The app's theme configuration class.
///
/// Provides a static [darkTheme] getter that returns a fully configured
/// [ThemeData] object. This can be extended with a [lightTheme] in the future.
class AppTheme {
  // Private constructor — this class should not be instantiated.
  AppTheme._();

  // -----------------------------------------------------------------------
  // Color Palette Constants
  // -----------------------------------------------------------------------

  /// Primary brand color — deep indigo for trust and intelligence.
  static const Color primaryColor = Color(0xFF4F46E5);

  /// Secondary brand color — cyan for tech and innovation.
  static const Color secondaryColor = Color(0xFF06B6D4);

  /// Accent color — amber for highlights and achievements.
  static const Color accentColor = Color(0xFFF59E0B);

  /// Success color — emerald green for positive states.
  static const Color successColor = Color(0xFF10B981);

  /// Error/danger color — red for error states.
  static const Color errorColor = Color(0xFFEF4444);

  /// Warning color — orange for caution.
  static const Color warningColor = Color(0xFFF97316);

  /// Background color — rich dark navy.
  static const Color backgroundColor = Color(0xFF0F172A);

  /// Surface color — slightly lighter for cards and elevated surfaces.
  static const Color surfaceColor = Color(0xFF1E293B);

  /// Card background color — for elevated components.
  static const Color cardColor = Color(0xFF334155);

  /// Primary text color — bright white for readability on dark backgrounds.
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Secondary text color — muted slate for less important text.
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Tertiary text color — even more muted for hints and captions.
  static const Color textTertiary = Color(0xFF64748B);

  // -----------------------------------------------------------------------
  // Gradient Definitions
  // -----------------------------------------------------------------------

  /// Primary gradient for buttons and hero elements.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient for the app scaffold.
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundColor, Color(0xFF1a1a2e)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Accent gradient for skill chips and badges.
  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // -----------------------------------------------------------------------
  // Theme Data
  // -----------------------------------------------------------------------

  /// Returns the app's dark theme configuration.
  ///
  /// Uses Material Design 3 with custom color scheme and typography
  /// powered by Google Fonts (Inter — clean, modern, highly readable).
  static ThemeData get darkTheme {
    return ThemeData(
      // Enable Material Design 3
      useMaterial3: true,

      // Brightness
      brightness: Brightness.dark,

      // Color Scheme — defines all the semantic colors
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // Scaffold background
      scaffoldBackgroundColor: backgroundColor,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration theme (text fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryColor.withAlpha(50),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: cardColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Text theme using Google Fonts
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
    );
  }
}
