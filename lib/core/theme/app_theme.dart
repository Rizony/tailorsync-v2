import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Colors ---
  static const Color brandBlue = Color(0xFF1E78D2);
  static const Color brandOrange = Color(0xFFF58220);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);

  // --- Typography System ---
  // We define the exact weights and sizes so it looks consistent everywhere.
  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.outfitTextTheme(base).copyWith(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1.0),
      displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600), // AppBars, Card Titles
      titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600), // ListTiles
      bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.normal), // Standard text
      bodyMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.normal), // Subtitles
      labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600), // Buttons
      labelSmall: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5), // Status Chips
    );
  }

  // --- Light Theme ---
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandBlue,
        primary: brandBlue,
        secondary: brandOrange,
        error: errorColor,
        brightness: Brightness.light,
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF1A1A1A), // Darker, softer black for better reading
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FC), // Very soft, premium off-white
      textTheme: _buildTextTheme(baseTheme.textTheme),
      
      // Page Transitions (Makes navigation feel like iOS/Premium Android)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0, // Prevents discoloration when scrolling
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: brandBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Premium Card Style (Soft shadow, no harsh borders)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.04), // Very soft, modern shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Inputs (Slightly softer borders, clean focus state)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandBlue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5), // Softer outline
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))), // Squircle shape
      ),
    );
  }

  // --- Dark Theme ---
  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandBlue,
        primary: brandBlue,
        secondary: brandOrange,
        error: errorColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
        onSurface: const Color(0xFFF5F5F5),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: _buildTextTheme(baseTheme.textTheme),
      
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: brandOrange, // High contrast for dark mode
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dark Mode Cards (No shadows in dark mode, just subtle borders)
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2C2C2C)), // Subtle dark border
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: Color(0xFF2C2C2C), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
  }
}
