enum SubscriptionTier {
  freemium(name: 'Freemium', monthlyPrice: 0),
  standard(name: 'Standard', monthlyPrice: 3000),
  premium(name: 'Premium', monthlyPrice: 5000);

  final String name;
  final int monthlyPrice;
  const SubscriptionTier({required this.name, required this.monthlyPrice});

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