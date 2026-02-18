import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tailorsync_v2/features/customers/models/customer.dart';

import 'package:tailorsync_v2/features/customers/repositories/customer_repository.dart';
import 'package:tailorsync_v2/features/customers/screens/add_edit_customer_screen.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';
import 'package:tailorsync_v2/features/jobs/screens/job_details_screen.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final Customer customer;
  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsByCustomerProvider(customer.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditCustomerScreen(customer: customer),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(customer.phoneNumber ?? 'No Phone'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.straighten),
                      title: Text("Measurements"),
                    ),
                    // Display measurements grid
                    if (customer.measurements.isNotEmpty)
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3,
                        children: customer.measurements.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${e.key}:", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(e.value.toString()),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No measurements recorded."),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Order History Header
            const Text(
              "Order History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Order List
            jobsAsync.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const Text("No orders found for this customer.");
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return ListTile(
                      tileColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat.yMMMd().format(job.createdAt)),
                      trailing: _buildStatusChip(job.status),
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailsScreen(job: job),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'quote': color = Colors.blue; break;
      case 'pending': color = Colors.orange; break;
      case 'completed': color = Colors.green; break;
      default: color = Colors.grey;
    }
    
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: const Text('This will permanently delete this customer and their measurements. Order history may remain but unlinked.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(customerRepositoryProvider.notifier).deleteCustomer(customer.id!);
        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            const SnackBar(content: Text('Customer deleted')),
          );
          await Future.delayed(const Duration(milliseconds: 50));
          if (context.mounted) {
             Navigator.pop(context); // Go back to list
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting customer: $e')),
          );
        }
      }
    }
  }
}
