import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../orders/order.dart';
import '../orders/order_id.dart';
import 'invoice.dart';
import 'invoice_factory.dart';
import 'invoice_repository.dart';

/// ------------------------------------------------------------
/// Bootstrap Provider (used once at app start)
/// ------------------------------------------------------------
final invoicesBootstrapProvider =
    FutureProvider<InvoicesController>((ref) async {
  final repo = InvoiceRepository();
  final controller = InvoicesController(repo);
  await controller.bootstrap();
  return controller;
});

/// ------------------------------------------------------------
/// Public Provider (overridden in main.dart)
/// ------------------------------------------------------------
final invoicesControllerProvider =
    StateNotifierProvider<InvoicesController, Map<OrderId, Invoice>>(
  (ref) {
    throw UnimplementedError(
      'InvoicesController must be provided from invoicesBootstrapProvider',
    );
  },
);

/// ------------------------------------------------------------
/// Controller
/// ------------------------------------------------------------
class InvoicesController
    extends StateNotifier<Map<OrderId, Invoice>> {
  final InvoiceRepository _repo;

  InvoicesController(this._repo) : super({});

  /// ------------------------------------------------------------
  /// Bootstrap
  /// ------------------------------------------------------------
  Future<void> bootstrap() async {
    final invoices = await _repo.loadAll();
    state = {
      for (final invoice in invoices)
        invoice.orderId: invoice,
    };
  }

  /// ------------------------------------------------------------
  /// Commands
  /// ------------------------------------------------------------
  void createFromOrder(Order order) {
    final invoice = InvoiceFactory.fromOrder(order);

    state = {
      ...state,
      order.id: invoice,
    };

    _persist();
  }

  void updateInvoice(Invoice invoice) {
    state = {
      ...state,
      invoice.orderId: invoice,
    };

    _persist();
  }

  /// ------------------------------------------------------------
  /// Persistence
  /// ------------------------------------------------------------
  Future<void> _persist() async {
    await _repo.saveAll(state.values.toList());
  }
}
