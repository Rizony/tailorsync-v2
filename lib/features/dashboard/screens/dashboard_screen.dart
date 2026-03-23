import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:needlix/features/dashboard/providers/dashboard_provider.dart';
import 'package:needlix/features/orders/models/order_model.dart';
import 'package:needlix/features/orders/screens/create_order_screen.dart';
import 'package:needlix/features/orders/screens/order_details_screen.dart';
import 'package:needlix/features/settings/screens/settings_screen.dart';
import 'package:needlix/features/customers/screens/add_edit_customer_screen.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/utils/tutorial_service.dart';
import 'package:needlix/core/providers/navigation_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/features/marketplace/repositories/marketplace_repository.dart';
import 'package:needlix/features/marketplace/screens/marketplace_requests_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _hasCheckedTutorial = false;

  void _checkTutorial(String? userId) async {
    if (_hasCheckedTutorial || userId == null) return;
    _hasCheckedTutorial = true;
    
    final hasSeen = await TutorialService.hasSeenTutorial(userId);
    if (!hasSeen && mounted) {
      TutorialService.showTutorial(context, userId);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardStatsProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final profile = profileAsync.valueOrNull;
    final currencySymbol = profile?.currencySymbol ?? '₦';
    
    // Check if shop details are missing
    final isProfileIncomplete = profile != null && 
        (profile.shopName == null || profile.shopName!.isEmpty ||
         profile.phoneNumber == null || profile.phoneNumber!.isEmpty);

    return Scaffold(
      body: dashboardAsync.when(
        data: (data) {
          final userId = Supabase.instance.client.auth.currentUser?.id;
          
          if (!_hasCheckedTutorial && userId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkTutorial(userId);
            });
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.refresh(dashboardStatsProvider.future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40), // Top padding for status bar
                  _buildHeader(context, data.userName).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                  if (isProfileIncomplete) ...[
                    const SizedBox(height: 16),
                    _buildProfileCompletionCard(context),
                  ],
                  const SizedBox(height: 24),
                  _buildStatsGrid(context, data, currencySymbol).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),
                  _buildMarketplaceWidget(context, ref),
                  const SizedBox(height: 24),
                  _buildQuickActions(context).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                  const SizedBox(height: 24),
                  if (data.urgentOrders.isNotEmpty) ...[
                    _buildUrgentOrders(context, data.urgentOrders, currencySymbol),
                    const SizedBox(height: 24),
                  ],
                  _buildRecentActivity(data.recentOrders, currencySymbol).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $name 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Text(
              'Here is your daily summary',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete Your Shop Profile',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add your shop name and phone number. This is important for generating professional PDF invoices and building trust in the community.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic data, String currencySymbol) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          context, 
          'Active Orders', 
          '${data.activeOrders}', 
          Icons.content_cut, 
          Colors.blue,
          onTap: () => ref.read(navigationProvider.notifier).state = AppTabs.orders,
        ),
        _buildStatCard(
          context, 
          'Pending', 
          '${data.activeOrders}', 
          Icons.assignment_late, 
          Colors.orange,
          onTap: () => ref.read(navigationProvider.notifier).state = AppTabs.orders,
        ),
        _buildStatCard(
          context, 
          'Customers', 
          '${data.totalCustomers}', 
          Icons.people, 
          Colors.purple,
          onTap: () => ref.read(navigationProvider.notifier).state = AppTabs.customers,
        ),
        _buildStatCard(
          context, 
          'Revenue', 
          '$currencySymbol${data.totalRevenue}', 
          Icons.attach_money, 
          Colors.green,
          onTap: () => ref.read(navigationProvider.notifier).state = AppTabs.orders, 
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            key: TutorialService.newOrderKey,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('New Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            key: TutorialService.addCustomerKey,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add Customer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentOrders(BuildContext context, List<OrderModel> orders, String currencySymbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Urgent Deliveries (Next 48h)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return _UrgentOrderCard(order: orders[index], currencySymbol: currencySymbol);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<OrderModel> orders, String currencySymbol) {
    if (orders.isEmpty) {
       return const Center(child: Text("No recent activity"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(order: order),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withValues(alpha: 0.1) 
                        : Colors.grey.shade200
                  ),
                ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          DateFormat.yMMMd().format(order.createdAt),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$currencySymbol${order.price}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case OrderModel.statusPending: return Colors.orange;
      case OrderModel.statusInProgress: return Colors.blue;
      case OrderModel.statusFitting: return Colors.purple;
      case OrderModel.statusAdjustment: return Colors.amber;
      case OrderModel.statusCompleted: return Colors.green;
      case OrderModel.statusDelivered: return Colors.grey;
      case OrderModel.statusCanceled: return Colors.red;
      case OrderModel.statusQuote: return Colors.cyan;
      default: return Colors.grey;
    }
  }

  Widget _buildMarketplaceWidget(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingMarketplaceRequestsCountProvider);
    if (pendingCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MarketplaceRequestsScreen()),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pendingCount New Inquiries!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Potential customers are reaching out from the website.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _UrgentOrderCard extends StatefulWidget {
  final OrderModel order;
  final String currencySymbol;

  const _UrgentOrderCard({required this.order, required this.currencySymbol});

  @override
  State<_UrgentOrderCard> createState() => _UrgentOrderCardState();
}

class _UrgentOrderCardState extends State<_UrgentOrderCard> {
  late DateTime _now;
  late Stream<DateTime> _timerStream;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timerStream = Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _timerStream,
      builder: (context, snapshot) {
        final now = snapshot.data ?? _now;
        final difference = widget.order.dueDate.difference(now);
        final hoursLeft = difference.inHours;
        final minutesLeft = difference.inMinutes % 60;
        
        final isVeryUrgent = hoursLeft < 12;
        final baseColor = isVeryUrgent ? Colors.red : Colors.orange;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsScreen(order: widget.order),
              ),
            );
          },
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? baseColor.withValues(alpha: 0.15)
                  : baseColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: baseColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.order.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16, 
                            color: baseColor.shade700
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCountdownBadge(hoursLeft, minutesLeft, baseColor),
                  ],
                ),
                Text(
                  'Due: ${DateFormat.jm().format(widget.order.dueDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.currencySymbol}${widget.order.balanceDue} due',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          )
                        ]
                      ),
                      child: Text(
                        widget.order.status.toUpperCase(),
                        style: TextStyle(
                          color: baseColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildCountdownBadge(int hours, int minutes, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '${hours}h ${minutes}m',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
