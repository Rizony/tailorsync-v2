import 'payment_method.dart';

class Payment {
  final double amount;
  final PaymentMethod method;
  final DateTime paidAt;
  final String? reference;

  const Payment._({
    required this.amount,
    required this.method,
    required this.paidAt,
    this.reference,
  });

  factory Payment.cash({
    required double amount,
    DateTime? paidAt,
  }) {
    return Payment._(
      amount: amount,
      method: PaymentMethod.cash,
      paidAt: paidAt ?? DateTime.now(),
    );
  }

  factory Payment.card({
    required double amount,
    required String reference,
    DateTime? paidAt,
  }) {
    return Payment._(
      amount: amount,
      method: PaymentMethod.card,
      reference: reference,
      paidAt: paidAt ?? DateTime.now(),
    );
  }

  factory Payment.bankTransfer({
    required double amount,
    required String reference,
    DateTime? paidAt,
  }) {
    return Payment._(
      amount: amount,
      method: PaymentMethod.bankTransfer,
      reference: reference,
      paidAt: paidAt ?? DateTime.now(),
    );
  }

  /// ✅ MOBILE MONEY (FIXES YOUR ERROR)
  factory Payment.mobileMoney({
    required double amount,
    required String reference,
    DateTime? paidAt,
  }) {
    return Payment._(
      amount: amount,
      method: PaymentMethod.mobileMoney,
      reference: reference,
      paidAt: paidAt ?? DateTime.now(),
    );
  }
}
