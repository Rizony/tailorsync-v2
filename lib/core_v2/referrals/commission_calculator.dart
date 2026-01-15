
import 'referral.dart';

class CommissionCalculator {
  static double calculateMonthlyEarning(Referral referral) {
    final price = referral.plan.monthlyPriceUsd;

    if (referral.isFirstMonth) {
      return price * 0.40;
    }

    return price * 0.10;
  }
}
