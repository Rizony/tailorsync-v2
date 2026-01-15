import '../monetization/subscription_plan.dart';
import 'referral.dart';

class ReferralEngine {
  static double totalMonthlyEarnings({
    required SubscriptionPlan referrerPlan,
    required List<Referral> referrals,
    required double Function(SubscriptionPlan) priceResolver,
    DateTime? now,
  }) {
    if (!referrerPlan.isPaid) return 0;
    if (!referrerPlan.canEarnReferrals) return 0;



    double total = 0;
    int activeCount = 0;

    for (final referral in referrals) {
      if (!referral.isActive) continue;
      if (activeCount >= 100) break;

      final price = priceResolver(referral.plan);
      final rate = referral.isFirstMonth ? 0.40 : 0.10;

      total += price * rate;
      activeCount++;
    }

    return total;
  }
}
