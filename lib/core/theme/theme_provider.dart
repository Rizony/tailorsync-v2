import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: In a production app, you would use SharedPreferences here to save 
// the user's choice so it persists when they close and reopen the app.

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system); // Default to system settings

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
