import 'package:tailorsync_v2/core_v2/monetization/earnings_breakdown.dart';
import 'package:tailorsync_v2/core_v2/referrals/referral.dart';
import 'package:tailorsync_v2/core_v2/referrals/referral_commission.dart';

import '../monetization/subscription_plan.dart';

class EarningsResolver {
  /// Delegte referral earnings calculation to ReferralEngine
  static double commissionForReferral({
    required int referralIndex,
    required SubscriptionPlan referrerPlan,
    required SubscriptionPlan refereePlan,
    required bool isFirstMonth,
  }) {
    return ReferralEngine.commissionForReferral(
      referralIndex: referralIndex,
      referrerPlan: referrerPlan,
      refereePlan: refereePlan,
      isFirstMonth: isFirstMonth,
    );
  }

  /// lightweight summary for dashboard / UI
  static EarningsBreakdown earningsSummary({
    required SubscriptionPlan referrerPlan,
    required int referralCount,
    required double price,
  }) {
    return breakdown(
      referrerPlan: referrerPlan,
      referralCount: referralCount,
      price: price,
    );
  }

  static double earningForReferral({
  required Referral referral,
  required SubscriptionPlan referrerPlan,
  required DateTime forMonth,
}) {
  if (!referrerPlan.canViewEarnings) return 0;
  if (!referral.isActive) return 0;

  final price = referral.plan.monthlyPriceUsd;

  if (referral.isFirstMonth) {
    return price * 0.40;
  }

  return price * 0.10;
}

  static double totalMonthlyEarnings({
    required SubscriptionPlan referrerPlan,
    required List<SubscriptionPlan> activeReferrals,
  }) {
    if (!referrerPlan.isPaid) return 0;

    double total = 0;

    for (int i = 0; i < activeReferrals.length && i < 100; i++) {
      final refereePlan = activeReferrals[i];

      if (!refereePlan.isPaid) continue;

      final rate = i == 0 ? 0.40 : 0.10;
      total += refereePlan.monthlyPriceUsd * rate;
    }

    return total;
  }

  /// Provides a breakdown of earnings based on referral count and plan price
  /// for a referrer.
  static EarningsBreakdown breakdown({  
    required SubscriptionPlan referrerPlan,
    required int referralCount,
    required double price,
  }) {
    if (!referrerPlan.isPaid || referralCount == 0) {
      return const EarningsBreakdown(
        firstMonth: 0,
        recurring: 0,
        total: 0,
      );
    }

    final firstMonth = price * 0.40;
    final recurring = (referralCount - 1) * price * 0.10;

    return EarningsBreakdown(
      firstMonth: firstMonth,
      recurring: recurring,
      total: firstMonth + recurring,
    );
  }
  
}
