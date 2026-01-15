import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/core_v2/customers/customer_measurement_controller.dart';
import 'package:tailorsync_v2/core_v2/customers/customer_measurements_controller.dart';
import 'package:tailorsync_v2/core_v2/measurements/garment_type.dart';
import 'package:tailorsync_v2/ui/customers/measurement_editor_screen.dart';
import 'package:tailorsync_v2/ui/orders/create_order_screen.dart';

import '../../core_v2/customers/customer.dart';
import '../../core_v2/customers/customer_id.dart';
import '../../core_v2/customers/customers_controller.dart';

import '../../core_v2/orders/order.dart';
import '../../core_v2/orders/orders_controller.dart';

import '../orders/order_detail_screen.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final CustomerId customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersControllerProvider);
    final orders = ref.watch(ordersControllerProvider);
    ref
    .watch(customerMeasurementProvider.notifier)
    .bookFor(customerId);

    final customer = customers[customerId];
    if (customer == null) {
      return const Scaffold(
        body: Center(child: Text('Customer not found')),
      );
    }

    

    final customerOrders = orders
        .where((o) => o.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                _showEditCustomerDialog(context, ref, customer),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOrderScreen(
          customerId: customer.id,
        ),
      ),
    );
  },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, 'Customer Info'),
          _infoRow('Name', customer.name),
          if (customer.phone != null)
            _infoRow('Phone', customer.phone!),
          if (customer.email != null)
            _infoRow('Email', customer.email!),
          _infoRow(
            'Customer since',
            _formatDate(customer.createdAt),
          ),

          const SizedBox(height: 24),

_sectionTitle(context, 'Measurements'),

Consumer(
  builder: (_, ref, __) {
    final book = ref
        .watch(customerMeasurementsProvider.notifier)
        .bookFor(customer.id);

    return Column(
      children: GarmentType.values.map((garment) {
        final profile = book.profileFor(garment);

        return Card(
          child: ListTile(
            title: Text(garment.name.toUpperCase()),
            subtitle: Text(
              profile == null
                  ? 'Not added'
                  : '${profile.measurements.length} fields',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MeasurementEditorScreen(
                    customerId: customer.id,
                    garment: garment,
                    existing: profile,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  },
),



          const SizedBox(height: 24),

          _sectionTitle(context, 'Orders'),
          if (customerOrders.isEmpty)
            const _EmptyOrders()
          else
            ...customerOrders.map(
              (order) => _OrderTile(order: order),
            ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(
    BuildContext context,
    WidgetRef ref,
    Customer customer,
  ) {
    final nameController =
        TextEditingController(text: customer.name);
    final phoneController =
        TextEditingController(text: customer.phone ?? '');
    final emailController =
        TextEditingController(text: customer.email ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration:
                    const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration:
                    const InputDecoration(labelText: 'Email'),
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
                ref
                    .read(customersControllerProvider.notifier)
                    .updateCustomer(
                      customer.copyWith(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim().isEmpty
                            ? null
                            : phoneController.text.trim(),
                        email: emailController.text.trim().isEmpty
                            ? null
                            : emailController.text.trim(),
                      ),
                    );

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _sectionTitle(BuildContext context, String text) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// ORDER TILE
/// ------------------------------------------------------------

class _OrderTile extends StatelessWidget {
  final Order order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Order #${order.id.value.substring(0, 6)}'),
        subtitle: Text(
          'Status: ${order.status.name}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(order: order),
            ),
          );
        },
      ),
    );
  }
}



class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context)


   {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'No orders yet for this customer.',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
