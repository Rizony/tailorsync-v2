import 'package:flutter/material.dart';

/// Brand colors that may change per partner or season
class BrandColors {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;

  final Color accent;
  final Color accentLight;

  const BrandColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.accentLight,
  });

  /// Default TailorSync brand
  static const defaultBrand = BrandColors(
    primary: Color(0xFF2962FF),
    primaryDark: Color(0xFF0039CB),
    primaryLight: Color(0xFFE3F2FD),
    accent: Color(0xFFFF6D00),
    accentLight: Color(0xFFFFE0B2),
  );
}
