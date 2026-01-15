import '../monetization/subscription_plan.dart';

class AdPolicy {
  static bool shouldShowAds(SubscriptionPlan plan) {
    return plan == SubscriptionPlan.free;
  }
}
