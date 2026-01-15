import 'package:uuid/uuid.dart';

import '../orders/order.dart';
import '../orders/order_status.dart';
import 'invoice.dart';
import 'invoice_id.dart';

class InvoiceFactory {
  static const _uuid = Uuid();

  static Invoice fromOrder(Order order) {
    if (order.status != OrderStatus.readyForDelivery) {
      throw StateError(
        'Invoice can only be created from ready orders',
      );
    }

    return Invoice(
      id: InvoiceId(_uuid.v4()),
      orderId: order.id,
      totalAmount: order.quotation.totalPrice,
      payments: const [],
      issuedAt: DateTime.now(),
    );
  }
}
