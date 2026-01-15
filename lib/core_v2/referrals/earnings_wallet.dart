class EarningsWallet {
  final double balance;
  final double lifetimeEarnings;

  const EarningsWallet({
    required this.balance,
    required this.lifetimeEarnings,
  });

  EarningsWallet credit(double amount) {
    return EarningsWallet(
      balance: balance + amount,
      lifetimeEarnings: lifetimeEarnings + amount,
    );
  }

  EarningsWallet debit(double amount) {
    return EarningsWallet(
      balance: balance - amount,
      lifetimeEarnings: lifetimeEarnings,
    );
  }
}
