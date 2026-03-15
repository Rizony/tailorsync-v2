import 'package:freezed_annotation/freezed_annotation.dart';

enum SubscriptionTier {
  @JsonValue('freemium')
  freemium(label: 'Freemium', monthlyPrice: 0),
  
  @JsonValue('standard')
  standard(label: 'Standard', monthlyPrice: 3000),
  
  @JsonValue('premium')
  premium(label: 'Premium', monthlyPrice: 5000);

  final String label;
  final int monthlyPrice;
  const SubscriptionTier({required this.label, required this.monthlyPrice});

  // Business Logic Helpers
  bool get hasAds => this == SubscriptionTier.freemium;
  bool get canPartner => this == SubscriptionTier.premium;
  
  // Updated: Freemium max is 50 customers (even with ads), 1 customer per ad watch
  int get customerLimit => this == SubscriptionTier.freemium ? 50 : 999999;
  
  // Maximum customers without ads (before watching ads)
  int get baseCustomerLimit => this == SubscriptionTier.freemium ? 20 : 999999;
  
  // Customers that can be added per ad watch
  int get customersPerAd => this == SubscriptionTier.freemium ? 1 : 0;
}