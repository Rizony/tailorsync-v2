import 'package:flutter/material.dart';
import 'package:tailorsync_v2/core_v2/orders/order_status.dart';

class OrderTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderTimeline({
    super.key,
    required this.currentStatus,
  });

  static const _steps = [
    OrderStatus.draft,
    OrderStatus.confirmed,
    OrderStatus.inProgress,
    OrderStatus.readyForDelivery,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _steps.map((status) {
        final currentIndex =
            _steps.indexOf(currentStatus);
        final stepIndex = _steps.indexOf(status);

        final isCompleted = stepIndex < currentIndex;
        final isActive = stepIndex == currentIndex;

        return ListTile(
          leading: Icon(
            isCompleted
                ? Icons.check_circle
                : isActive
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
            color: isCompleted || isActive
                ? Theme.of(context)
                    .colorScheme
                    .primary
                : Colors.grey,
          ),
          title: Text(_label(status)),
          subtitle:
              isActive ? const Text('Current stage') : null,
        );
      }).toList(),
    );
  }

  String _label(OrderStatus status) {
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
 