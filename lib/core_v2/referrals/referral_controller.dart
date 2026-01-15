import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import '../monetization/subscription_plan.dart';
import 'referral.dart';
import 'commission_calculator.dart';
import 'earnings_wallet.dart';

final referralControllerProvider =
    StateNotifierProvider<ReferralController, EarningsWallet>(
  (ref) => ReferralController(ref),
);

class ReferralController extends StateNotifier<EarningsWallet> {
  final Ref ref;
  final List<Referral> _referrals = [];

  ReferralController(this.ref)
      : super(const EarningsWallet(balance: 0, lifetimeEarnings: 0));

  bool get canRefer {
    final session = ref.read(sessionControllerProvider).session;
    return session.plan == SubscriptionPlan.premium &&
        _referrals.length < 100;
  }

  void addReferral(Referral referral) {
    if (!canRefer) return;

    _referrals.add(referral);

    final earning =
        CommissionCalculator.calculateMonthlyEarning(referral);

    state = state.credit(earning);
  }
}
