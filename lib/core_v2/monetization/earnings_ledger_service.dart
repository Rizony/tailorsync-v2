import 'payout_rules.dart';
import 'earnings_ledger_entry.dart';
import '../referrals/referral.dart';
import 'earnings_resolver.dart';
import 'subscription_plan.dart';

class EarningsLedgerService {
  static List<EarningsLedgerEntry> generateLedger({
    required List<DateTime> months,
    required List<Referral> referrals,
    required SubscriptionPlan referrerPlan,
  }) {
    double runningBalance = 0;
    final List<EarningsLedgerEntry> ledger = [];

    for (final month in months) {
      double monthlyTotal = 0;

      final activeReferrals = referrals
          .where((r) => r.isActive)
          .length;

      for (final referral in referrals) {
        if (!referral.isActive) continue;

        final earning =
            EarningsResolver.earningForReferral(
          referral: referral,
          referrerPlan: referrerPlan,
          forMonth: month,
        );

        if (earning > 0) {
          monthlyTotal += earning;
        }
      }

      monthlyTotal = _round(monthlyTotal);
      runningBalance = _round(
        runningBalance + monthlyTotal,
      );

      final isPayable =
          runningBalance >= PayoutRules.minimumPayoutUsd;

      ledger.add(
        EarningsLedgerEntry(
          year: month.year,
          month: month.month,
          referralCount: activeReferrals,
          amountUsd: monthlyTotal,
          rolloverBalanceUsd: runningBalance,
          isPayable: isPayable,
          isSettled: false,
          isLocked: true,
        ),
      );

      // Reset ONLY after payout eligibility
      if (isPayable) {
        runningBalance = 0;
      }
    }

    return ledger;
  }

  static double _round(double value) =>
      double.parse(value.toStringAsFixed(2));
}
