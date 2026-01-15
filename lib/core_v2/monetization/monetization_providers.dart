import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import 'feature_access.dart';
import 'subscription_plan.dart';

/// Current subscription plan
final subscriptionPlanProvider = Provider<SubscriptionPlan>((ref) {
  return ref.watch(sessionControllerProvider).session.plan;
});

/// Whether the user can earn referrals
final canEarnReferralsProvider = Provider<bool>((ref) {
  final plan = ref.watch(subscriptionPlanProvider);
  return FeatureAccess.canUse(
    AppFeature.partnerProgram,
    plan,
  );
});

/// Monthly referral earnings (computed)
final monthlyEarningsProvider = Provider<double>((ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (s) => s.monthlyReferralEarnings,
    ),
  );
});

/// Number of active referrals
final referralCountProvider = Provider<int>((ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (s) => s.session.referralCount,
    ),
  );
});
