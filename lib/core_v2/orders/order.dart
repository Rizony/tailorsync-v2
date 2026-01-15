import 'package:tailorsync_v2/core_v2/orders/order_measurement_snapshot.dart';

import '../customers/customer_id.dart';
import '../quotation/quotation.dart';
import 'order_id.dart';
import 'order_item.dart';
import 'order_status.dart';

class Order {
  final OrderId id;
  final CustomerId customerId;

  /// One or more garments in this order.
  /// Must never be empty.
  final List<OrderItem> items;

  /// Accepted quotation that produced this order.
  final Quotation quotation;

  /// Current business lifecycle status.
  final OrderStatus status;

  /// When the order was created.
  final DateTime createdAt;

  /// When tailoring work was completed.
  final DateTime? workCompletedAt;

  /// When the order was delivered to the customer.
  final DateTime? deliveredAt;

  /// When the order was cancelled.
  final DateTime? cancelledAt;

  final OrderMeasurementSnapshot? measurementSnapshot;

  const Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.quotation,
    required this.status,
    required this.createdAt,
    this.workCompletedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.measurementSnapshot,
  }) : assert(items.length > 0, 'Order must contain at least one item');

  /// Orders that are still relevant operationally
  /// (including delivery and post-delivery support).
  bool get isWorkActive =>
    status == OrderStatus.confirmed ||
    status == OrderStatus.inProgress;

bool get isBusinessActive =>
    status != OrderStatus.cancelled;

      
  /// Controlled mutation entry point.
  Order copyWith({
    OrderStatus? status,
    List<OrderItem>? items,
    DateTime? workCompletedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) {
    return Order(
      id: id,
      customerId: customerId,
      items: items ?? this.items,
      quotation: quotation,
      status: status ?? this.status,
      createdAt: createdAt,
      workCompletedAt: workCompletedAt ?? this.workCompletedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
