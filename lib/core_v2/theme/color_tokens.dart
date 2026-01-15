import 'package:flutter/material.dart';

class ColorTokens {
  // Neutrals
  final Color background;
  final Color surface;
  final Color border;

  // Text
  final Color textPrimary;
  final Color textSecondary;

  // Semantic
  final Color error;
  final Color success;

  const ColorTokens({
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
  });

  static const light = ColorTokens(
    background: Color(0xFFF8F9FB),
    surface: Colors.white,
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
  );

  static const dark = ColorTokens(
    background: Color(0xFF0F172A),
    surface: Color(0xFF020617),
    border: Color(0xFF1E293B),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFCBD5E1),
    error: Color(0xFFF87171),
    success: Color(0xFF4ADE80),
  );
  /// ✅ DEFAULT LIGHT TOKENS
  static const defaultTokens = ColorTokens(
    background: Color(0xFFF8F9FB),
    surface: Colors.white,
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
  );
}
