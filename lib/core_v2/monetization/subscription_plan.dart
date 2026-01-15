enum SubscriptionPlan {
  free,
  standard,
  premium;

  bool get isPaid => this != SubscriptionPlan.free;
  bool get canEarnReferrals => this != SubscriptionPlan.free;
  bool get canViewEarnings => this != SubscriptionPlan.free;
  bool get canAccessPremiumFeatures =>
      this == SubscriptionPlan.premium;

  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.standard:
        return 'Standard';
      case SubscriptionPlan.premium:
        return 'Premium';
    }
  }

  double get monthlyPriceUsd {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.standard:
        return 3;
      case SubscriptionPlan.premium:
        return 5;
    }
  }
}
