import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/features/orders/repositories/order_repository.dart';
import 'package:needlix/features/orders/screens/create_order_screen.dart';
import 'package:needlix/features/orders/screens/order_details_screen.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/theme/components/empty_state_widget.dart';
import 'package:needlix/core/theme/components/premium_card.dart';
import 'package:needlix/core/theme/app_colors.dart';
import 'package:needlix/core/theme/app_typography.dart';

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
          return EmptyStateWidget(
            icon: Icons.shopping_bag_outlined,
            title: searchQuery.isEmpty ? 'No Orders Yet' : 'No Results Found',
            description: searchQuery.isEmpty 
              ? 'Start by creating your first order. Your business is about to grow!' 
              : 'Try a different search term or check your spelling.',
            actionButton: searchQuery.isEmpty ? ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Order'),
            ) : null,
          );
        }
        return ListView.builder(
          itemCount: filteredOrders.length,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80, top: 8), 
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            final currency = profile?.currencySymbol ?? '₦';
            
            return PremiumCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  order.title, 
                  style: AppTypography.label.copyWith(fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.customerName != null) 
                       Padding(
                         padding: const EdgeInsets.only(top: 2.0),
                         child: Text(order.customerName!, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
                       ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(DateFormat.yMMMd().format(order.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        if (OrderModel.activeStatuses.contains(order.status)) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.access_time, size: 12, color: _isOverdue(order) ? Colors.red : Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${DateFormat.MMMd().format(order.dueDate)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isOverdue(order) ? Colors.red : Colors.grey[600],
                              fontWeight: _isOverdue(order) ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildStatusChip(context, order.status),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currency${NumberFormat('#,###').format(order.price)}', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (order.balanceDue > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Bal: $currency${NumberFormat('#,###').format(order.balanceDue)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (order.price > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PAID',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
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
                  );
                },
              ),
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color, 
          fontSize: 9, 
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
