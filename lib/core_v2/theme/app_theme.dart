import 'package:flutter/material.dart';
import '../branding/brand_colors.dart';
import 'color_tokens.dart';
import 'typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build({
    required BrandColors brand,
    required ColorTokens tokens,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: tokens.background,

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: brand.primary,
        onPrimary: Colors.white,
        secondary: brand.accent,
        onSecondary: Colors.white,
        error: tokens.error,
        onError: Colors.white,
        surface: tokens.surface,
        onSurface: tokens.textPrimary,
      ),

      textTheme: AppTypography.textTheme(
        tokens.textPrimary,
        tokens.textSecondary,
      ),

      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.border),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: tokens.textPrimary,
      ),
    );
  }
  
}
