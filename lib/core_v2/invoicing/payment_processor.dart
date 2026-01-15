import 'invoice.dart';
import 'payment.dart';

class PaymentProcessor {
  static Invoice applyPayment({
    required Invoice invoice,
    required Payment payment,
  }) {
    if (invoice.isCancelled) {
      throw StateError(
        'Cannot pay a cancelled invoice',
      );
    }

    return invoice.addPayment(payment);
  }
}
