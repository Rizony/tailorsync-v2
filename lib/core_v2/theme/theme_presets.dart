import 'package:flutter/material.dart';
import '../branding/brand_colors.dart';
import 'color_tokens.dart';
import 'app_theme.dart';

class ThemePresets {
  static ThemeData light({
    required BrandColors brand,
    required ColorTokens tokens,
  }) {
    return AppTheme.build(
      brand: brand,
      tokens: tokens,
      brightness: Brightness.light,
    );
  }

  static ThemeData dark({
    required BrandColors brand,
    required ColorTokens tokens,
  }) {
    return AppTheme.build(
      brand: brand,
      tokens: tokens,
      brightness: Brightness.dark,
    );
  }

  static ThemeData seasonal({
    required BrandColors brand,
    required ColorTokens tokens,
  }) {
    // seasonal = light + different tokens/brand
    return AppTheme.build(
      brand: brand,
      tokens: tokens,
      brightness: Brightness.light,
    );
  }
}
