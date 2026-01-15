import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../orders/order_id.dart';
import 'invoice.dart';
import 'invoice_repository.dart';
import 'invoices_controller.dart';

final invoicesControllerProvider =
    StateNotifierProvider<InvoicesController, Map<OrderId, Invoice>>(
  (ref) {
    final repo = InvoiceRepository();
    final controller = InvoicesController(repo);

    // eager load persisted invoices
    controller.bootstrap();

    return controller;
  },
);
