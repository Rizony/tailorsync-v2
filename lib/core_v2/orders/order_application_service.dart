import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/orders/order_alteration.dart';

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
  Order addAlteration({
  required Order order,
  required OrderAlteration alteration,
}) {
  return order.copyWith(
    alterations: [...order.alterations, alteration],
  );
}

}

final orderApplicationServiceProvider =
    Provider<OrderApplicationService>((ref) {
  return OrderApplicationService(ref);
});

Order addAlteration({
  required Order order,
  required OrderAlteration alteration,
}) {
  return order.copyWith(
    alterations: [...order.alterations, alteration],
  );
}

