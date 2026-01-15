import 'order.dart';
import 'order_status.dart';

class OrderStateMachine {
  static bool canTransition(
    OrderStatus from,
    OrderStatus to,
  ) {
    switch (from) {
      case OrderStatus.draft:
        return to == OrderStatus.confirmed ||
            to == OrderStatus.cancelled;

      case OrderStatus.confirmed:
        return to == OrderStatus.inProgress ||
            to == OrderStatus.cancelled;

      case OrderStatus.inProgress:
        return to == OrderStatus.readyForDelivery;

      case OrderStatus.readyForDelivery:
        return false;

      case OrderStatus.cancelled:
        return false;
    }
  }

  static Order advance(Order order) {
    switch (order.status) {
      case OrderStatus.draft:
        return _transition(order, OrderStatus.confirmed);

      case OrderStatus.confirmed:
        return _transition(order, OrderStatus.inProgress);

      case OrderStatus.inProgress:
        return _transition(order, OrderStatus.readyForDelivery);

      case OrderStatus.readyForDelivery:
      case OrderStatus.cancelled:
        return order;
    }
  }

  static Order cancel(Order order) {
    if (!canTransition(order.status, OrderStatus.cancelled)) {
      return order;
    }

    return order.copyWith(
      status: OrderStatus.cancelled,
      cancelledAt: DateTime.now(),
    );
  }

  static Order _transition(Order order, OrderStatus to) {
    if (!canTransition(order.status, to)) return order;

    return order.copyWith(
      status: to,
      workCompletedAt: to == OrderStatus.readyForDelivery
          ? DateTime.now()
          : order.workCompletedAt,
    );
  }
}
