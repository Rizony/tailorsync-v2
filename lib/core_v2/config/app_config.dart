class AppConfig {
  // ---- Monetization ----
  static const int maxPartnerReferrals = 100;

  static const double firstMonthCommission = 0.40;
  static const double recurringCommission = 0.10;

  // ---- Ads ----
  static const bool adsEnabledForFreePlan = true;

  // ---- Feature Flags (future proofing) ----
  static const bool seasonalThemesEnabled = true;
  static const bool partnerBrandingEnabled = true;

  // ---- App Identity ----
  static const String appName = 'TailorSync';
}
