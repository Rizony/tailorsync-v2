import 'package:flutter/material.dart';
import 'package:tailorsync_v2/core_v2/orders/order.dart';
import 'package:tailorsync_v2/core_v2/orders/order_status.dart';
import 'package:tailorsync_v2/ui/orders/order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  final List<Order> orders;

  const OrdersScreen({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final visibleOrders = orders
        .where((o) => o.status != OrderStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: ListView.builder(
        itemCount: visibleOrders.length,
        itemBuilder: (context, index) {
          final order = visibleOrders[index];

          return ListTile(
            leading: _statusIcon(order.status),
            title: Text(
              order.quotation.garment.name.toUpperCase(),
            ),
            subtitle: Text(
              'Customer: ${order.customerId.value}',
            ),
            trailing: Text(
              _statusLabel(order.status),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OrderDetailScreen(order: order),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Icon _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return const Icon(Icons.edit_note);
      case OrderStatus.confirmed:
        return const Icon(Icons.check_circle_outline);
      case OrderStatus.inProgress:
        return const Icon(Icons.work_outline);
      case OrderStatus.readyForDelivery:
        return const Icon(Icons.local_shipping_outlined);
      case OrderStatus.cancelled:
        return const Icon(Icons.cancel_outlined);
    }
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.readyForDelivery:
        return 'Ready for Delivery';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
