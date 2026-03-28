import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:needlix/features/customers/models/customer.dart';

import 'package:needlix/features/customers/repositories/customer_repository.dart';
import 'package:needlix/features/customers/screens/add_edit_customer_screen.dart';
import 'package:needlix/features/orders/repositories/order_repository.dart';
import 'package:needlix/features/orders/screens/order_details_screen.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/app_colors.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/core/theme/components/empty_state_widget.dart';
import 'package:needlix/core/utils/snackbar_util.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final Customer customer;
  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersByCustomerProvider(customer.id!));

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
            // Customer Profile Avatar
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 3),
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: customer.photoUrl != null ? NetworkImage(customer.photoUrl!) : null,
                  child: customer.photoUrl == null 
                      ? Text(customer.fullName[0].toUpperCase(), style: AppTypography.h1.copyWith(color: AppColors.primary))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Customer Info Card
            PremiumCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone, color: AppColors.primary),
                    title: Text(customer.phoneNumber ?? 'No Phone', style: AppTypography.bodyMedium),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.straighten, color: AppColors.primary),
                    title: Text("Measurements", style: AppTypography.label),
                  ),
                  // Display measurements grid
                  if (customer.measurements.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3,
                        children: customer.measurements.entries.map((e) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text("${e.key}:",
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  e.value.toString(),
                                  style: AppTypography.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No measurements recorded."),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Order History Header
            Text(
              "Order History",
              style: AppTypography.h3,
            ),
            const SizedBox(height: 12),

            // Order List
            ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Text("No orders found for this customer.");
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return PremiumCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        title: Text(order.title, style: AppTypography.label),
                        subtitle: Text(DateFormat.yMMMd().format(order.createdAt), style: AppTypography.bodySmall),
                        trailing: _buildStatusChip(order.status),
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(order: order),
                            ),
                          );
                        },
                      ),
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
        if (context.mounted) showErrorSnackBar(context, e);
      }
    }
  }
}
