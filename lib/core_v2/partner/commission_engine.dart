import '../config/app_config.dart';
import '../monetization/subscription_plan.dart';

class CommissionEngine {
  /// Returns commission rate for a given month
  static double commissionRate({
    required SubscriptionPlan referrerPlan,
    required SubscriptionPlan referredPlan,
    required int referralIndex,
    required bool isFirstMonth,
  }) {
    // Only premium users can earn
    if (referrerPlan != SubscriptionPlan.premium) {
      return 0.0;
    }

    // Only paid users generate commission
    if (referredPlan == SubscriptionPlan.free) {
      return 0.0;
    }

    // Referral limit
    if (referralIndex >= AppConfig.maxPartnerReferrals) {
      return 0.0;
    }

    if (isFirstMonth) {
      return AppConfig.firstMonthCommission;
    }

    return AppConfig.recurringCommission;
  }
}
