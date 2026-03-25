import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF0076B6);
  static const Color primaryLight = Color(0xFF00AEEF); // Cyan
  static const Color primaryDark = Color(0xFF005A8C);
  
  // Secondary / Dark background
  static const Color secondary = Color(0xFF0A1128); // Midnight Blue
  static const Color secondaryLight = Color(0xFF1A2138);
  static const Color secondaryDark = Color(0xFF050A1A);

  // Background and Surface
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = Color(0xFF0A1128);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  // State colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textHintLight = Color(0xFF94A3B8); // Slate 400

  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate 300
  static const Color textHintDark = Color(0xFF64748B); // Slate 500

  // Borders and Dividers
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDark = Color(0xFF334155); // Slate 700

  // Gradients
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPremiumGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
