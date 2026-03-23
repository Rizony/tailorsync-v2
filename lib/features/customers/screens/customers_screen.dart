import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:needlix/core/widgets/premium_empty_state.dart';

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
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
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
                  return PremiumEmptyState(
                    icon: Icons.person_add_alt_1_outlined,
                    title: _searchQuery.isEmpty ? 'Your Customer List' : 'No Results Found',
                    message: _searchQuery.isEmpty 
                      ? 'Add your regular customers to keep track of their measurements and orders.' 
                      : 'Try a different search term or check your spelling.',
                    actionLabel: _searchQuery.isEmpty ? 'Add Customer' : null,
                    onAction: _searchQuery.isEmpty ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
                      );
                    } : null,
                  );
                }

                return ListView.separated(
                  itemCount: filteredCustomers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        backgroundImage: customer.photoUrl != null ? NetworkImage(customer.photoUrl!) : null,
                        child: customer.photoUrl == null 
                            ? Text(customer.fullName[0].toUpperCase())
                            : null,
                      ),
                      title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(customer.phoneNumber ?? 'No phone number'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerDetailsScreen(customer: customer),
                          ),
                        );
                      },
                    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1);
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
