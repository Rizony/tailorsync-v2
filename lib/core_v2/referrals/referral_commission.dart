// core_v2/referrals/referral_commission.dart
import '../monetization/subscription_plan.dart';

class ReferralEngine {
  static const int maxReferrals = 100;

  static double commissionForReferral({
    required int referralIndex,
    required SubscriptionPlan referrerPlan,
    required SubscriptionPlan refereePlan,
    required bool isFirstMonth,
  }) {
    if (!referrerPlan.isPaid) return 0;
    if (!refereePlan.isPaid) return 0;
    if (referralIndex > maxReferrals) return 0;

    final rate = isFirstMonth ? 0.40 : 0.10;
    return refereePlan.monthlyPriceUsd * rate;
  }
}
