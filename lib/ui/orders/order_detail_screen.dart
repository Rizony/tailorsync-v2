import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/invoicing/invoices_provider.dart';

import 'package:tailorsync_v2/core_v2/orders/order.dart';
import 'package:tailorsync_v2/core_v2/orders/order_application_service.dart';
import 'package:tailorsync_v2/core_v2/orders/order_status.dart';

import 'package:tailorsync_v2/core_v2/invoicing/payment.dart';
import 'package:tailorsync_v2/ui/orders/widgets/order_measurements_card.dart';

import 'order_timeline.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() =>
      _OrderDetailScreenState();
}

class _OrderDetailScreenState
    extends ConsumerState<OrderDetailScreen> {
  late Order _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoicesControllerProvider);

    final bool hasInvoice =
        invoices.containsKey(_order.id);

    final invoice =
        hasInvoice ? invoices[_order.id]! : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _sectionTitle('Order Info'),          
    if (_order.measurementSnapshot != null) ...[
  _sectionTitle('Measurements'),
  OrderMeasurementsCard(
    snapshot: _order.measurementSnapshot!,
  ),
] else ...[
  _sectionTitle('Measurements'),
  const Text(
    'No measurements locked for this order.',
    style: TextStyle(color: Colors.grey),
  ),
],
            const SizedBox(height: 12),
            _infoRow('Order ID', _order.id.value),
            _infoRow('Status', _order.status.name),
            _infoRow(
              'Total',
              '\$${_order.quotation.totalPrice.toStringAsFixed(2)}',
            ),

            const SizedBox(height: 24),

            _sectionTitle('Order Progress'),
            OrderTimeline(currentStatus: _order.status),

            const SizedBox(height: 24),

            _sectionTitle('Actions'),

            if (_canAdvance(_order))
  ElevatedButton(
    onPressed: () {
      final service =
          ref.read(orderApplicationServiceProvider);

      setState(() {
        _order = service.advance(_order);
      });
    },
    child: const Text('Advance Order'),
  ),
          
            if (invoice != null) ...[
              const SizedBox(height: 24),
              _sectionTitle('Invoice'),

              _infoRow('Invoice ID', invoice.id.value),
              _infoRow('Status', invoice.status.name),
              _infoRow(
                'Balance Due',
                '\$${invoice.balanceDue.toStringAsFixed(2)}',
              ),

              if (!invoice.isPaid)
                ElevatedButton(
                  onPressed: () {
                    final updated = invoice.addPayment(
                      Payment.cash(
                        amount: invoice.balanceDue,
                      ),
                    );

                    ref
                        .read(
                          invoicesControllerProvider
                              .notifier,
                        )
                        .updateInvoice(updated);
                  },
                  child: const Text('Mark as Paid'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canAdvance(Order order) {
    return order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.readyForDelivery;
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style:
                const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
