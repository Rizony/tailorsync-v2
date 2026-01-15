import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order.dart';
import 'order_state_machine.dart';
import 'order_status.dart';
import '../invoicing/invoices_controller.dart';

class OrderApplicationService {
  final Ref ref;

  OrderApplicationService(this.ref);

  Order advance(Order order) {
    final updated = OrderStateMachine.advance(order);

    // ✅ DOMAIN RULE: auto-generate invoice
    if (updated.status == OrderStatus.readyForDelivery) {
      final invoices =
          ref.read(invoicesControllerProvider);

      final existing =
          invoices[updated.id];

      if (existing == null) {
        ref
            .read(invoicesControllerProvider.notifier)
            .createFromOrder(updated);
      }
    }

    return updated;
  }
}

final orderApplicationServiceProvider =
    Provider<OrderApplicationService>((ref) {
  return OrderApplicationService(ref);
});
