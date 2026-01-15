import 'package:uuid/uuid.dart';

import '../customers/customer_id.dart';
import '../quotation/quotation.dart';
import 'order.dart';
import 'order_id.dart';
import 'order_item.dart';
import 'order_status.dart';

class OrderFactory {
  static const _uuid = Uuid();

  static Order create({
    required CustomerId customerId,
    required Quotation quotation,
    required List<OrderItem> items,
  }) {
    return Order(
      id: OrderId(_uuid.v4()),
      customerId: customerId,
      items: items,
      quotation: quotation,
      status: OrderStatus.draft,
      createdAt: DateTime.now(),
    );
  }
}
