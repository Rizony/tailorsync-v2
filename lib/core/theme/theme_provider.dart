import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system); 

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

// Dynamically select the primary brand color based on subscription tier
final themeColorProvider = Provider<Color>((ref) {
  final profileAsync = ref.watch(profileNotifierProvider);
  final tier = profileAsync.valueOrNull?.subscriptionTier ?? SubscriptionTier.freemium;

  switch (tier) {
    case SubscriptionTier.premium:
      return const Color(0xFF00AEEF); // Cyan for Premium
    case SubscriptionTier.standard:
      return const Color(0xFF0076B6); // Deep Blue for Standard
    case SubscriptionTier.freemium:
      return const Color(0xFF455A64); // Blue Grey for Freemium
  }
});
