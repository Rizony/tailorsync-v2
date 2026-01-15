import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/ui/customers/customer_detail_screen.dart';

import '../../core_v2/customers/customer.dart';
import '../../core_v2/customers/customers_controller.dart';

class CustomersListScreen extends ConsumerWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersMap = ref.watch(customersControllerProvider);
    final customers = customersMap.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: customers.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _CustomerTile(
                  customer: customers[index],
                );
              },
            ),
    );
  }

  void _showAddCustomerDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                ref
                    .read(customersControllerProvider.notifier)
                    .addCustomer(
                      name: name,
                      phone: phoneController.text.trim().isEmpty
                          ? null
                          : phoneController.text.trim(),
                      email: emailController.text.trim().isEmpty
                          ? null
                          : emailController.text.trim(),
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
}

/// ------------------------------------------------------------
/// UI COMPONENTS
/// ------------------------------------------------------------

class _CustomerTile extends StatelessWidget {
  final Customer customer;

  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null)
              Text('📞 ${customer.phone}'),
            if (customer.email != null)
              Text('✉️ ${customer.email}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CustomerDetailScreen(
        customerId: customer.id,
      ),
    ),
  );
},

      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64),
          SizedBox(height: 16),
          Text(
            'No customers yet',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text('Tap + to add your first customer'),
        ],
      ),
    );
  }
}
