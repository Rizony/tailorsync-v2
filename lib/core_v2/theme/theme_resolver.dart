import 'package:flutter/material.dart';

import '../branding/brand_colors.dart';
import 'color_tokens.dart';
import '../session/user_session.dart';

class ThemeResolver {
  static ThemeData resolve({
    required BrandColors brand,
    required UserSession session,
  }) {
    final tokens = session.isDarkMode
        ? ColorTokens.dark
        : ColorTokens.light;

    final colorScheme = ColorScheme(
      brightness:
          session.isDarkMode ? Brightness.dark : Brightness.light,
      primary: brand.primary,
      onPrimary: Colors.white,
      secondary: brand.accent,
      onSecondary: Colors.white,
      error: tokens.error,
      onError: Colors.white,
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
    );
  }
}
