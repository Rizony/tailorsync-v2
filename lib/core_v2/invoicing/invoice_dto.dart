import 'invoice.dart';
import 'payment.dart';
import 'invoice_id.dart';
import '../orders/order_id.dart';
import 'payment_method.dart';

class InvoiceDto {
  static Map<String, dynamic> toJson(Invoice invoice) {
    return {
      'id': invoice.id.value,
      'orderId': invoice.orderId.value,
      'totalAmount': invoice.totalAmount,
      'isCancelled': invoice.isCancelled,
      'issuedAt': invoice.issuedAt.toIso8601String(),
      'payments': invoice.payments.map(_paymentToJson).toList(),
    };
  }

  static Invoice fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: InvoiceId(json['id'] as String),
      orderId: OrderId(json['orderId'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      isCancelled: json['isCancelled'] as bool,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      payments: (json['payments'] as List)
          .map(
            (p) => _paymentFromJson(p as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  static Map<String, dynamic> _paymentToJson(Payment p) {
    return {
      'amount': p.amount,
      'method': p.method.name,
      'paidAt': p.paidAt.toIso8601String(),
      'reference': p.reference,
    };
  }

  static Payment _paymentFromJson(Map<String, dynamic> json) {
    final method = PaymentMethod.values.firstWhere(
      (m) => m.name == json['method'],
    );

    final amount = (json['amount'] as num).toDouble();
    final paidAt = DateTime.parse(json['paidAt'] as String);
    final reference = json['reference'] as String?;

    switch (method) {
      case PaymentMethod.cash:
        return Payment.cash(
          amount: amount,
          paidAt: paidAt,
        );

      case PaymentMethod.card:
      case PaymentMethod.bankTransfer:
      case PaymentMethod.mobileMoney:
        return Payment.card(
          amount: amount,
          reference: reference ?? method.name.toUpperCase(),
          paidAt: paidAt,
        );
    }
  }
}
