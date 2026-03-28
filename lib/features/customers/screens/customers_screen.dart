import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:needlix/core/theme/components/empty_state_widget.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/app_colors.dart';
import 'package:needlix/core/theme/app_typography.dart';
import 'package:needlix/core/theme/components/custom_text_field.dart';
import 'package:needlix/features/customers/repositories/customer_repository.dart';
import 'package:needlix/features/customers/screens/customer_details_screen.dart';
import 'package:needlix/features/customers/screens/add_edit_customer_screen.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CustomTextField(
              label: '',
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                final filteredCustomers = customers.where((c) {
                  return c.fullName.toLowerCase().contains(_searchQuery) ||
                         (c.phoneNumber?.contains(_searchQuery) ?? false);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.person_add_alt_1_outlined,
                    title: _searchQuery.isEmpty ? 'Your Customer List' : 'No Results Found',
                    description: _searchQuery.isEmpty 
                      ? 'Add your regular customers to keep track of their measurements and orders.' 
                      : 'Try a different search term or check your spelling.',
                    actionButton: _searchQuery.isEmpty ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Customer'),
                    ) : null,
                  );
                }

                return ListView.builder(
                  itemCount: filteredCustomers.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return PremiumCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            backgroundImage: customer.photoUrl != null ? NetworkImage(customer.photoUrl!) : null,
                            child: customer.photoUrl == null 
                                ? Text(customer.fullName[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))
                                : null,
                          ),
                        ),
                        title: Text(customer.fullName, style: AppTypography.label.copyWith(fontSize: 16)),
                        subtitle: Text(customer.phoneNumber ?? 'No phone number', style: AppTypography.bodySmall.copyWith(color: Colors.grey[600])),
                        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailsScreen(customer: customer),
                            ),
                          );
                        },
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (index * 30).ms).slideX(begin: 0.05);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditCustomerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
