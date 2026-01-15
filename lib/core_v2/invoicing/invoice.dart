import 'dart:collection';

import '../orders/order_id.dart';
import 'invoice_id.dart';
import 'invoice_status.dart';
import 'payment.dart';

class Invoice {
  final InvoiceId id;
  final OrderId orderId;
  final double totalAmount;
  final bool isCancelled;
  final DateTime issuedAt;

  final List<Payment> _payments;

  const Invoice({
    required this.id,
    required this.orderId,
    required this.totalAmount,
    required List<Payment> payments,
    this.isCancelled = false,
    required this.issuedAt,
  }) : _payments = payments;

  UnmodifiableListView<Payment> get payments =>
      UnmodifiableListView(_payments);

  double get paidAmount =>
      _round(_payments.fold(0.0, (s, p) => s + p.amount));

  double get balanceDue =>
      _round((totalAmount - paidAmount).clamp(0, totalAmount));

  bool get isPaid => balanceDue == 0 && !isCancelled;

  InvoiceStatus get status {
    if (isCancelled) return InvoiceStatus.cancelled;
    if (isPaid) return InvoiceStatus.paid;
    if (paidAmount == 0) return InvoiceStatus.issued;
    return InvoiceStatus.partiallyPaid;
  }

  Invoice addPayment(Payment payment) {
    if (isCancelled) {
      throw StateError('Cannot pay a cancelled invoice');
    }
    if (paidAmount + payment.amount > totalAmount) {
      throw StateError('Payment exceeds invoice total');
    }

    return copyWith(
      payments: [..._payments, payment],
    );
  }

  Invoice cancel() {
    if (paidAmount > 0) {
      throw StateError('Cannot cancel paid invoice');
    }
    return copyWith(isCancelled: true);
  }

  Invoice copyWith({
    List<Payment>? payments,
    bool? isCancelled,
  }) {
    return Invoice(
      id: id,
      orderId: orderId,
      totalAmount: totalAmount,
      payments: payments ?? _payments,
      isCancelled: isCancelled ?? this.isCancelled,
      issuedAt: issuedAt,
    );
  }

  static double _round(double v) =>
      double.parse(v.toStringAsFixed(2));
}
