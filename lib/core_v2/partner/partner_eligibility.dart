import '../monetization/subscription_plan.dart';
import '../config/app_config.dart';

class PartnerEligibility {
  static bool canEarn({
    required SubscriptionPlan plan,
    required int currentReferrals,
  }) {
    if (plan != SubscriptionPlan.premium) return false;
    if (currentReferrals >= AppConfig.maxPartnerReferrals) return false;
    return true;
  }
}
