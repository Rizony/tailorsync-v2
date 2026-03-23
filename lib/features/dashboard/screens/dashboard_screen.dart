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
import 'package:needlix/features/monetization/screens/report_center_screen.dart';
import 'package:needlix/features/monetization/screens/wallet_dashboard_screen.dart';
import 'package:needlix/features/referrals/screens/referral_dashboard_screen.dart';
import 'package:needlix/features/support/screens/support_list_screen.dart';

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
      key: GlobalKey<ScaffoldState>(),
      drawer: _buildDrawer(context, profile, currencySymbol),
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
                  if (Supabase.instance.client.auth.currentUser?.emailConfirmedAt == null) ...[
                    const SizedBox(height: 16),
                    _buildVerificationBanner(context),
                  ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Your business at a glance',
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) => InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_rounded, 
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_email_unread_outlined, color: Colors.orange, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify Your Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please check your inbox and verify your email address to enable all features, including secure password recovery and payouts.',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final email = Supabase.instance.client.auth.currentUser?.email;
                          if (email != null) {
                            await Supabase.instance.client.auth.resend(
                              type: OtpType.signup,
                              email: email,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Verification email resent!')),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Resend Email'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => ref.refresh(dashboardStatsProvider),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('I\'ve verified'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          'Report Center', 
          '${data.weeklyRevenue.toStringAsFixed(0)}', 
          Icons.analytics_outlined, 
          Colors.green,
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportCenterScreen()),
            );
          }, 
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
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
                        '$currencySymbol${NumberFormat('#,###').format(order.price)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
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
                            fontSize: 9,
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

  Widget _buildDrawer(BuildContext context, dynamic profile, String currencySymbol) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    backgroundImage: profile?.logoUrl != null ? NetworkImage(profile!.logoUrl!) : null,
                    child: profile?.logoUrl == null ? const Icon(Icons.store, size: 35, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile?.shopName ?? 'TailorSync Shop',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                Text(
                  profile?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context, 
                  Icons.dashboard_outlined, 
                  'Dashboard', 
                  isActive: true,
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  context, 
                  Icons.style_outlined, 
                  'Orders', 
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(navigationProvider.notifier).state = 1; // AppTabs.orders
                  },
                ),
                _buildDrawerItem(
                  context, 
                  Icons.people_outline, 
                  'Customers', 
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(navigationProvider.notifier).state = 2; // AppTabs.customers
                  },
                ),
                _buildDrawerItem(
                  context, 
                  Icons.forum_outlined, 
                  'Community', 
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(navigationProvider.notifier).state = 3; // AppTabs.community
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                _buildDrawerItem(
                  context, 
                  Icons.analytics_outlined, 
                  'Report Center', 
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportCenterScreen()));
                  },
                ),
                _buildDrawerItem(
                  context, 
                  Icons.account_balance_wallet_outlined, 
                  'Escrow Wallet', 
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletDashboardScreen()));
                  },
                ),
                _buildDrawerItem(
                   context, 
                   Icons.handshake_outlined, 
                   'Partner Program', 
                   onTap: () {
                     Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralDashboardScreen()));
                   },
                 ),
                const Divider(indent: 16, endIndent: 16),
                _buildDrawerItem(
                  context, 
                  Icons.settings_outlined, 
                  'Settings', 
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
                _buildDrawerItem(
                  context, 
                  Icons.help_outline, 
                  'Help & Support', 
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportListScreen()));
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          _buildDrawerItem(
            context, 
            Icons.logout, 
            'Logout', 
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              // Handle logout logic from SettingsScreen or shared utility
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    {bool isActive = false, VoidCallback? onTap, Color? iconColor, Color? textColor}
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? (isActive ? Theme.of(context).colorScheme.primary : Colors.grey)),
      title: Text(
        title, 
        style: TextStyle(
          color: textColor ?? (isActive ? Theme.of(context).colorScheme.primary : null),
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
     // This matches the logic in SettingsScreen
     // For simplicity, we trigger the log out via ref directly if needed, 
     // or just navigate to settings and let it handle? 
     // Re-implementing here for immediate access.
     final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: baseColor.withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16, 
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
                      '${widget.currencySymbol}${NumberFormat('#,###').format(widget.order.balanceDue)} due',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.order.status.toUpperCase(),
                        style: TextStyle(
                          color: baseColor,
                          fontSize: 9,
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
