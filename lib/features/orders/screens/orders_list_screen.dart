import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/features/orders/repositories/order_repository.dart';
import 'package:needlix/features/orders/screens/create_order_screen.dart';
import 'package:needlix/features/orders/screens/order_details_screen.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/widgets/premium_empty_state.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Quotes'),
            Tab(text: 'Completed'),
            Tab(text: 'Canceled'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Orders or Customers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(onPressed: () => setState(() => _searchController.clear()), icon: const Icon(Icons.clear))
                  : null,
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrdersList(statuses: OrderModel.activeStatuses, searchQuery: _searchController.text),
                _OrdersList(statuses: const [OrderModel.statusQuote], searchQuery: _searchController.text),
                _OrdersList(statuses: const [OrderModel.statusCompleted, OrderModel.statusDelivered], searchQuery: _searchController.text),
                _OrdersList(statuses: const [OrderModel.statusCanceled], searchQuery: _searchController.text),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final List<String> statuses;
  final String searchQuery;
  const _OrdersList({required this.statuses, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersFuture = ref.watch(ordersByStatusesProvider(statuses));
    final profile = ref.watch(profileNotifierProvider).valueOrNull;

    return ordersFuture.when(
      data: (orders) {
        final filteredOrders = orders.where((order) {
           final query = searchQuery.toLowerCase();
           final titleMatch = order.title.toLowerCase().contains(query);
           final customerMatch = order.customerName?.toLowerCase().contains(query) ?? false;
           return titleMatch || customerMatch;
        }).toList();

        if (filteredOrders.isEmpty) {
          return PremiumEmptyState(
            icon: Icons.shopping_bag_outlined,
            title: searchQuery.isEmpty ? 'No Orders Yet' : 'No Results Found',
            message: searchQuery.isEmpty 
              ? 'Start by creating your first order. Your business is about to grow!' 
              : 'Try a different search term or check your spelling.',
            actionLabel: searchQuery.isEmpty ? 'New Order' : null,
            onAction: searchQuery.isEmpty ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
              );
            } : null,
          );
        }
        return ListView.builder(
          itemCount: filteredOrders.length,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80), // Added bottom padding for FAB
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  isThreeLine: true,
                  title: Text(order.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.customerName != null) 
                         Text(order.customerName!, style: Theme.of(context).textTheme.bodyMedium),
                      Row(
                        children: [
                          Text(DateFormat.yMMMd().format(order.createdAt), style: Theme.of(context).textTheme.bodySmall),
                          if (statuses.contains(OrderModel.statusPending) || 
                              statuses.contains(OrderModel.statusInProgress)) ...[
                            Text(' • ', style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              'Due: ${DateFormat.MMMd().format(order.dueDate)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _isOverdue(order) ? Theme.of(context).colorScheme.error : null,
                                fontWeight: _isOverdue(order) ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(context, order.status),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${profile?.currencySymbol ?? '₦'}${order.price}', 
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (order.balanceDue > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'Bal: ${profile?.currencySymbol ?? '₦'}${order.balanceDue.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (order.price > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'PAID',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  bool _isOverdue(OrderModel order) {
    return order.status == OrderModel.statusPending && 
           order.dueDate.isBefore(DateTime.now());
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status) {
      case OrderModel.statusPending: color = Colors.orange; break;
      case OrderModel.statusInProgress: color = Theme.of(context).colorScheme.primary; break;
      case OrderModel.statusFitting: color = Colors.purple; break;
      case OrderModel.statusAdjustment: color = Colors.amber; break;
      case OrderModel.statusCompleted: color = Theme.of(context).colorScheme.secondary; break; 
      case OrderModel.statusDelivered: color = Colors.grey; break;
      case OrderModel.statusCanceled: color = Theme.of(context).colorScheme.error; break;
      case OrderModel.statusQuote: color = Colors.cyan; break;
      default: color = Colors.grey;
    }

    if (status == OrderModel.statusCompleted) {
         color = const Color(0xFF43A047); 
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
