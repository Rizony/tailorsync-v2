import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/features/monetization/models/subscription_tier.dart';

class UserSubscription {
  final SubscriptionTier tier;
  final int customersAdded;
  final bool adWatchedToday;

  UserSubscription({
    required this.tier,
    this.customersAdded = 0,
    this.adWatchedToday = false,
  });

  // Business Logic: Can they add a customer?
  // Updated: Freemium users can add up to 50 customers (20 base + 30 via ads)
  bool get canAddCustomer {
    if (tier != SubscriptionTier.freemium) return true;
    return customersAdded < 50; // Freemium max limit (including ad credits)
  }

  // Business Logic: Is the app locked behind a daily ad?
  bool get isEntryLocked => tier == SubscriptionTier.freemium && !adWatchedToday;
}

// We'll use this to watch the user's status across the app
final subscriptionProvider = StateProvider<UserSubscription>((ref) {
  return UserSubscription(tier: SubscriptionTier.freemium);
});