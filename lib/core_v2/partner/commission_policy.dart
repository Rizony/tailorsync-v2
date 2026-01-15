import '../monetization/subscription_plan.dart';

class CommissionPolicy {
  static double commissionRate(SubscriptionPlan plan) {
    if (plan == SubscriptionPlan.premium) {
      return 0.40; // 40%
    }
    return 0.0;
  }

  static bool canRefer(SubscriptionPlan plan) {
    return plan == SubscriptionPlan.premium;
  }
}
