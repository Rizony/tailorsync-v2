import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order.dart';
import 'order_factory.dart';
import 'order_state_machine.dart';
import '../customers/customer_id.dart';
import '../quotation/quotation.dart';
import 'order_item.dart';

final ordersControllerProvider =
    StateNotifierProvider<OrdersController, List<Order>>(
  (ref) => OrdersController(),
);

class OrdersController extends StateNotifier<List<Order>> {
  OrdersController() : super(const []);

  void createOrder({
    required CustomerId customerId,
    required Quotation quotation,
    required List<OrderItem> items,
  }) {
    state = [
      ...state,
      OrderFactory.create(
        customerId: customerId,
        quotation: quotation,
        items: items,
      ),
    ];
  }

  void advanceOrder(Order order) {
    state = [
      for (final o in state)
        if (o.id == order.id)
          OrderStateMachine.advance(o)
        else
          o,
    ];
  }

  void cancelOrder(Order order) {
    state = [
      for (final o in state)
        if (o.id == order.id)
          OrderStateMachine.cancel(o)
        else
          o,
    ];
  }
}
