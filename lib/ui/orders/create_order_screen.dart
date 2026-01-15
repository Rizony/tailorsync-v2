import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/customers/customer_measurements_controller.dart';
import 'package:tailorsync_v2/core_v2/orders/order_measurement_snapshot_factory.dart';

import '../../core_v2/customers/customer_id.dart';
import '../../core_v2/orders/order_item.dart';
import '../../core_v2/orders/orders_controller.dart';
import '../../core_v2/quotation/quotation.dart';
import '../../core_v2/quotation/quotation_status.dart';
import '../../core_v2/quotation/quotation_line_item.dart';
import '../../core_v2/measurements/garment_type.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  final CustomerId customerId;

  const CreateOrderScreen({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<CreateOrderScreen> createState() =>
      _CreateOrderScreenState();
}

class _CreateOrderScreenState
    extends ConsumerState<CreateOrderScreen> {
  final List<OrderItem> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text('No garments added yet'),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final item = _items[i];
                        return Card(
                          child: ListTile(
                            title: Text(
                              item.garment.name.toUpperCase(),
                            ),
                            subtitle: Text(
                              '${item.description} • Qty: ${item.quantity}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(i);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Garment'),
              onPressed: _showAddGarmentDialog,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _items.isEmpty
                  ? null
                  : () => _confirm(context),
              child: const Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ADD GARMENT
  // ------------------------------------------------------------

  void _showAddGarmentDialog() {
    GarmentType selectedGarment = GarmentType.shirt;
    final descriptionController = TextEditingController();
    final quantityController =
        TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Garment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<GarmentType>(
                initialValue: selectedGarment,
                items: GarmentType.values
                    .map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text(g.name),
                      ),
                    )
                    .toList(),
                onChanged: (g) {
                  if (g != null) selectedGarment = g;
                },
                decoration:
                    const InputDecoration(labelText: 'Garment'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
  final book = ref
      .read(customerMeasurementsProvider.notifier)
      .bookFor(widget.customerId);

  final profile = book.profileFor(selectedGarment);

  if (profile == null) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'No measurements found for ${selectedGarment.name}. Please add measurements first.',
        ),
      ),
    );
    return;
  }

  final snapshot =
      OrderMeasurementSnapshotFactory.fromProfile(profile);

  setState(() {
    _items.add(
      OrderItem(
        garment: selectedGarment,
        description: descriptionController.text.trim(),
        quantity:
            int.tryParse(quantityController.text) ?? 1,
        measurements: snapshot, // 🔒 LOCKED
      ),
    );
  });

  Navigator.pop(context);
},

              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // CONFIRM ORDER
  // ------------------------------------------------------------

  void _confirm(BuildContext context) {
    /// TEMPORARY quotation — valid but simple
    final quotation = Quotation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: widget.customerId,
      garment: _items.first.garment,
      items: _items
          .map(
            (i) => QuotationLineItem(
              label: i.description,
              amount: 0, // pricing comes later
            ),
          )
          .toList(),
      subtotal: 0,
      discount: 0,
      total: 0,
      status: QuotationStatus.finalized,
      createdAt: DateTime.now(),
      finalizedAt: DateTime.now(),
    );

    ref.read(ordersControllerProvider.notifier).createOrder(
          customerId: widget.customerId,
          quotation: quotation,
          items: _items,
        );

    Navigator.pop(context);
  }
}
