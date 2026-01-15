class PayoutRules {
  static const double minimumPayoutUsd = 50.0;

  static bool canPayout(double amountUsd) {
    return amountUsd >= minimumPayoutUsd;
  }

  static bool isPayableBalance(double balanceUsd) {
    return canPayout(balanceUsd);
  }
}
